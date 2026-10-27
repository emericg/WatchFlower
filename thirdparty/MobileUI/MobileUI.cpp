/*!
 * Copyright (c) 2016 J-P Nurmi
 * Copyright (c) 2026 Emeric Grange
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "MobileUI.h"

#if defined(Q_OS_IOS)
#include "MobileUI_ios.h"
#elif defined(Q_OS_ANDROID)
#include "MobileUI_android.h"
#else
#include "MobileUI_private.h"
#endif

#include <QGuiApplication>
#include <QStyleHints>
#include <QInputMethod>
#include <QMetaEnum>
#include <QQmlEngine>
#include <QScreen>
#include <QWindow>
#include <QTimer>
#include <QDebug>

#include <algorithm>
#include <cmath>

/* ************************************************************************** */

MobileUI *MobileUI::getInstance()
{
    static MobileUI *instance = new MobileUI(QCoreApplication::instance());
    return instance;
}

MobileUI *MobileUI::create(QQmlEngine *, QJSEngine *)
{
    MobileUI *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

/* ************************************************************************** */

MobileUI::MobileUI(QObject *parent) : QObject(parent)
{
#if defined(Q_OS_IOS)
    m_platform = new IosMobileUI(this);
#elif defined(Q_OS_ANDROID)
    m_platform = new AndroidMobileUI(this);
#else
    m_platform = new PlatformMobileUI(this);
#endif

    m_systemBarColorsSupported = m_platform->getSystemBarColorsSupported();

    // The backend may emit these from a native thread, the connections are then queued.
    connect(m_platform, &PlatformMobileUI::safeAreaMetricsUpdated, this, &MobileUI::applySafeAreas);
    connect(m_platform, &PlatformMobileUI::keyboardHeightUpdated, this, &MobileUI::applyKeyboardHeight);
    connect(m_platform, &PlatformMobileUI::deviceThemeUpdated, this, &MobileUI::applyDeviceTheme);
    connect(m_platform, &PlatformMobileUI::screenBrightnessUpdated, this, &MobileUI::applyScreenBrightness);

    // A light/dark mode change does not emit orientationChanged/visibilityChanged,
    // so make sure we re-read the device theme and re-apply our settings.
    if (QStyleHints *hints = qApp->styleHints())
    {
        connect(hints, &QStyleHints::colorSchemeChanged,
                this, [this](Qt::ColorScheme) { refreshDeviceTheme(); refreshMobileUI(); });
    }

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    // Track the on-screen keyboard height through Qt's input method (cross-platform).
    // Important caveat:
    // This is driven by Qt's input-method signals (keyboardRectangleChanged / visibleChanged)
    // Implementing a real WindowInsets(Animation) native listener on Android requires
    // a Java/Kotlin helper class, which is... Too heavy...
    // In practice Qt fires these signals when the keyboard shows/hides, which is
    // enough for everything except tracking the keyboard's slide-in/out per frame animation.
    if (QInputMethod *im = qApp->inputMethod())
    {
        connect(im, &QInputMethod::keyboardRectangleChanged, m_platform, &PlatformMobileUI::refreshKeyboardHeight);
        connect(im, &QInputMethod::visibleChanged, m_platform, &PlatformMobileUI::refreshKeyboardHeight);
    }

    // Set up the retry timers used by refreshMobileUI()
    for (unsigned i = 0; i < 4; ++i)
    {
        m_retryTimers[i].setSingleShot(true);
        m_retryTimers[i].setInterval(m_retryDelays[i]);
        connect(&m_retryTimers[i], &QTimer::timeout, this, [this]() {
            refreshSystemBars();
            refreshSafeAreas();
        });
    }

    QScreen *screen = qApp->primaryScreen();
    if (screen)
    {
        const QSizeF size = screen->physicalSize(); // in millimeters
        const double screenSizeInch = std::hypot(size.width(), size.height()) / 25.4;

        if (screenSizeInch >= 7.0) m_isTablet = true;
        else m_isPhone = true;
    }

    // The application window doesn't exist yet when this object is created from QML,
    // so we defer the signal hookup and the first safe area computation (and mostly
    // everything else too) until the event loop is running.
    QTimer::singleShot(0, this, [this]() {
        connectSignals(); // connectSignals() must be called only ONCE

        refreshDeviceTheme();
        refreshSystemBars();
        refreshSafeAreas();
        refreshScreenBrightness();
    });
#else
    // Desktop platforms: the device theme follows the color scheme reported by Qt.
    refreshDeviceTheme();
#endif
}

/* ************************************************************************** */

void MobileUI::connectSignals()
{
    // When orientation changes, we need to at least recompute the safe areas.
    // Track the primary screen until the application window is known (then its own screen, see refreshWindow()).

    trackScreen(qApp->primaryScreen());

    // The application window may not exist yet, or be replaced later,
    // so track it through focus changes (its own signals are connected in refreshWindow()).

    QObject::connect(qApp, &QGuiApplication::focusWindowChanged,
                     this, [this](QWindow *) { if (refreshWindow()) refreshMobileUI(); });
    refreshWindow();

    // The OS may reset the native system bar styles/colors when the application
    // returns to the foreground, so we re-apply them when becoming active again.

    QObject::connect(qApp, &QGuiApplication::applicationStateChanged,
                     this, [this](Qt::ApplicationState state) {
        if (state != Qt::ApplicationActive) return;
        refreshTorch();
        refreshScreenBrightness();
        refreshMobileUI();
    });
}

/* ************************************************************************** */

/*!
 * \brief Tell whether a window can be tracked as the application window.
 * \param window: the window to check (may be nullptr).
 * \return true for a top-level, regular window (not a popup, tooltip, dialog...).
 */
static bool isApplicationWindow(const QWindow *window)
{
    return window && window->isTopLevel() && window->type() == Qt::Window;
}

bool MobileUI::refreshWindow()
{
    QWindow *window = QGuiApplication::focusWindow();
    if (!isApplicationWindow(window)) window = nullptr;

    // No focus window while the application is in the background, keep tracking the current one
    if (!window) window = m_platform->getWindow();

    if (!window)
    {
        const QWindowList windows = QGuiApplication::topLevelWindows();
        for (QWindow *w : windows)
        {
            if (isApplicationWindow(w) && w->isVisible())
            {
                window = w;
                break;
            }
        }
    }

    if (window == m_platform->getWindow()) return false;

    for (const QMetaObject::Connection &connection : std::as_const(m_windowConnections))
    {
        QObject::disconnect(connection);
    }
    m_windowConnections.clear();

    m_platform->setWindow(window);

    if (window)
    {
        m_windowConnections << QObject::connect(window, &QWindow::visibilityChanged,
                                                this, [this](QWindow::Visibility) { refreshMobileUI(); });

        // The window may move to another screen (external display, foldable inner/outer display...)
        m_windowConnections << QObject::connect(window, &QWindow::screenChanged,
                                                this, [this](QScreen *screen) { trackScreen(screen); refreshMobileUI(); });

        // The insets may change without any rotation nor visibility change
        // (split-screen, freeform window or iPad multitasking resize, foldables...)
#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
        m_windowConnections << QObject::connect(window, &QWindow::safeAreaMarginsChanged,
                                                this, [this](QMargins) { refreshSafeAreas(); });
#else
        m_windowConnections << QObject::connect(window, &QWindow::widthChanged,
                                                this, [this](int) { refreshMobileUI(); });
        m_windowConnections << QObject::connect(window, &QWindow::heightChanged,
                                                this, [this](int) { refreshMobileUI(); });
#endif

        trackScreen(window->screen());

        // An orientation lock set before the window was available may have been ignored
        refreshScreenOrientation();
    }

    return true;
}

void MobileUI::trackScreen(QScreen *screen)
{
    QObject::disconnect(m_screenOrientationConnection);

    if (screen)
    {
        m_screenOrientationConnection = QObject::connect(screen, &QScreen::orientationChanged,
                                                         this, [this](Qt::ScreenOrientation) { refreshMobileUI(); });
    }
}

/* ************************************************************************** */

void MobileUI::refreshMobileUI()
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    // Re-apply the native bar colors / themes (lost on rotation or resume)
    refreshSystemBars();

    // Re-compute safe areas (changed on rotation)
    refreshSafeAreas();

    // After an orientation or visibility change the native insets and bar sizes are not always settled immediately,
    // so re-read them a few times with increasing delays until they stabilize.
    for (unsigned i = 0; i < 4; ++i)
    {
        m_retryTimers[i].start();
    }
#endif
}

/* ************************************************************************** */

void MobileUI::refreshDeviceTheme()
{
    m_platform->refreshDeviceTheme();
}

void MobileUI::applyDeviceTheme(MobileUI::Theme theme)
{
    if (theme != m_osTheme)
    {
        m_osTheme = theme;

        // The Auto bar themes may fall back on the device theme, so re-derive them
        for (SystemBar *bar : {&m_statusbar, &m_navbar})
        {
            if (deriveBarTheme(*bar))
            {
                applyBarTheme(*bar);
                notifyBar(*bar);
            }
        }

        Q_EMIT deviceThemeUpdated();
    }
}

void MobileUI::refreshSystemBars()
{
    for (const SystemBar *bar : {&m_statusbar, &m_navbar})
    {
        applyBarColor(*bar);
        applyBarTheme(*bar);
    }
}

void MobileUI::refreshScreenOrientation()
{
    if (m_screenOrientation != MobileUI::Unlocked)
    {
        m_platform->setScreenLockOrientation(m_screenOrientation);
    }
}

/* ************************************************************************** */

void MobileUI::setStatusbarColor(const QColor &color)
{
    //qDebug() << "MobileUI::setStatusbarColor(" << color.name() << ") luminance:" << colorLuminance(color);
    setBarColor(m_statusbar, color);
}

void MobileUI::setStatusbarContentColor(const QColor &color)
{
    setBarContentColor(m_statusbar, color);
}

void MobileUI::setStatusbarTheme(const MobileUI::Theme theme)
{
    if (!QMetaEnum::fromType<MobileUI::Theme>().valueToKey(theme))
    {
        qWarning() << "MobileUI::setStatusbarTheme() ignoring unknown theme:" << theme;
        return;
    }

    setBarTheme(m_statusbar, theme);
}

/* ************************************************************************** */

void MobileUI::setNavbarColor(const QColor &color)
{
    //qDebug() << "MobileUI::setNavbarColor(" << color.name() << ") luminance:" << colorLuminance(color);
    setBarColor(m_navbar, color);
}

void MobileUI::setNavbarContentColor(const QColor &color)
{
    setBarContentColor(m_navbar, color);
}

void MobileUI::setNavbarTheme(const MobileUI::Theme theme)
{
    if (!QMetaEnum::fromType<MobileUI::Theme>().valueToKey(theme))
    {
        qWarning() << "MobileUI::setNavbarTheme() ignoring unknown theme:" << theme;
        return;
    }

    setBarTheme(m_navbar, theme);
}

/* ************************************************************************** */

void MobileUI::setBarColor(SystemBar &bar, const QColor &color)
{
    if (!color.isValid()) return;

    bool changed = (bar.color != color);

    // Re-apply anyway, and battle with the OS fighting us...
    bar.color = color;
    applyBarColor(bar);

    // In "auto" mode, the theme follows the reference color, so re-resolve it.
    if (deriveBarTheme(bar))
    {
        applyBarTheme(bar);
        changed = true;
    }

    if (changed) notifyBar(bar);
}

void MobileUI::setBarContentColor(SystemBar &bar, const QColor &color)
{
    bool changed = (bar.contentColor != color);

    bar.contentColor = color;

    // In "auto" mode, the theme follows the reference color, so re-resolve it.
    if (deriveBarTheme(bar))
    {
        applyBarTheme(bar);
        changed = true;
    }

    if (changed) notifyBar(bar);
}

void MobileUI::setBarTheme(SystemBar &bar, const MobileUI::Theme theme)
{
    const MobileUI::Theme previousTheme = bar.theme;
    const MobileUI::Theme previousThemeSet = bar.themeSet;

    bar.theme = theme;
    if (theme > MobileUI::Auto) bar.themeSet = theme;
    else deriveBarTheme(bar);

    // Re-apply anyway, the OS might have changed that on its own
    applyBarTheme(bar);

    if (bar.theme != previousTheme || bar.themeSet != previousThemeSet) notifyBar(bar);
}

/*!
 * \brief Tell whether a color can be used to derive a system bar theme.
 * \param color: the color to check.
 * \return true if the color is valid and opaque.
 *
 * The perceived contrast of a translucent color depends on what is painted underneath,
 * which MobileUI can't know, so translucent colors are never used.
 */
static bool isReferenceColor(const QColor &color)
{
    return (color.isValid() && color.alpha() == 255);
}

bool MobileUI::deriveBarTheme(SystemBar &bar) const
{
    if (bar.theme != MobileUI::Auto) return false;

    MobileUI::Theme theme = m_osTheme;
    if (isReferenceColor(bar.contentColor))
    {
        theme = isColorLight_android(bar.contentColor) ? MobileUI::Light : MobileUI::Dark;
    }
    else if (isReferenceColor(bar.color))
    {
        theme = isColorLight_android(bar.color) ? MobileUI::Light : MobileUI::Dark;
    }

    if (theme == bar.themeSet) return false;

    bar.themeSet = theme;
    return true;
}

void MobileUI::applyBarColor(const SystemBar &bar)
{
    if (!m_systemBarColorsSupported || !bar.color.isValid()) return;

    if (&bar == &m_statusbar) m_platform->setColor_statusbar(bar.color);
    else m_platform->setColor_navbar(bar.color);
}

void MobileUI::applyBarTheme(const SystemBar &bar)
{
    if (bar.themeSet == MobileUI::Auto) return;

    if (&bar == &m_statusbar) m_platform->setTheme_statusbar(bar.themeSet);
    else m_platform->setTheme_navbar(bar.themeSet);
}

void MobileUI::notifyBar(const SystemBar &bar)
{
    if (&bar == &m_statusbar) Q_EMIT statusbarUpdated();
    else Q_EMIT navbarUpdated();
}

/* ************************************************************************** */

void MobileUI::refreshSafeAreas()
{
    m_platform->refreshSafeAreaMetrics();
}

void MobileUI::applySafeAreas(const MobileUI::SafeAreaMetrics &m)
{
    MobileUI::SafeAreaMetrics metrics = m;

    const QWindow *window = m_platform->getWindow();
    const bool fullscreenMode = (window && window->visibility() == QWindow::FullScreen);

    // When the window is in "full screen" mode, the system bars are not shown
    if (fullscreenMode)
    {
        metrics.statusbarHeight = 0;
        metrics.navbarHeight = 0;
    }

    // The top/bottom safe areas integrate the visible status/navigation bars
    metrics.top = std::max(metrics.top, metrics.statusbarHeight);
    metrics.bottom = std::max(metrics.bottom, metrics.navbarHeight);

    // Notify the UI safeAreas have changed, if needed
    if (metrics != m_safeAreas)
    {
        m_safeAreas = metrics;
        Q_EMIT safeAreaUpdated();
    }
}

/* ************************************************************************** */

void MobileUI::applyKeyboardHeight(int height)
{
    if (height < 0)
    {
        // Fall back to Qt's input method
        QInputMethod *im = qApp->inputMethod();
        height = (im && im->isVisible()) ? qRound(im->keyboardRectangle().height()) : 0;
    }

    if (height != m_keyboardHeight)
    {
        m_keyboardHeight = height;
        Q_EMIT keyboardUpdated();
    }
}

/* ************************************************************************** */

void MobileUI::refreshScreenBrightness()
{
    m_platform->refreshScreenBrightness();
}

void MobileUI::applyScreenBrightness(int value)
{
    // Some OEMs use an extended OS brightness range, reported above 100 by the backend
    value = std::clamp(value, 0, 100);

    if (value == m_screenBrightnessSystem) return;

    m_screenBrightnessSystem = value;

    // Only visible when the application has not set its own brightness
    if (m_screenBrightness < 0) Q_EMIT brightnessUpdated();
}

void MobileUI::setScreenBrightness(int value)
{
    // Negative values release the override, values above 100 are clamped
    value = (value < 0) ? -1 : std::min(value, 100);

    const int previous = getScreenBrightness();

    // We re-apply, the OS might have changed that on its own
    m_screenBrightness = value;
    m_platform->setScreenBrightness(value);

    // Once released, the OS wide brightness may have changed meanwhile
    if (value < 0) refreshScreenBrightness();

    if (getScreenBrightness() != previous) Q_EMIT brightnessUpdated();
}

/* ************************************************************************** */

void MobileUI::setScreenLockOrientation(const MobileUI::ScreenLockOrientation orientation)
{
    if (!QMetaEnum::fromType<MobileUI::ScreenLockOrientation>().valueToKey(orientation))
    {
        qWarning() << "MobileUI::setScreenLockOrientation() ignoring unknown orientation:" << orientation;
        return;
    }

    const bool changed = (orientation != m_screenOrientation);

    // We re-apply anyway, the OS might have changed that on its own
    m_screenOrientation = orientation;
    m_platform->setScreenLockOrientation(orientation);

    // Forcing the screen orientation does not emit QScreen::orientationChanged,
    // so we refresh the safe areas ourselves
    refreshMobileUI();

    if (changed) Q_EMIT screenUpdated();
}

/* ************************************************************************** */

void MobileUI::setScreenAlwaysOn(const bool value)
{
    const bool changed = (value != m_screenAlwaysOn);

    // We re-apply, the OS might have changed that on its own
    m_screenAlwaysOn = value;
    m_platform->setScreenAlwaysOn(value);

    if (changed) Q_EMIT screenUpdated();
}

/* ************************************************************************** */

void MobileUI::setScreenHighRefreshRate(const bool value)
{
    const bool changed = (value != m_screenHighRefreshRate);

    m_screenHighRefreshRate = value;
    m_platform->setScreenHighRefreshRate(value);

    if (changed) Q_EMIT screenUpdated();
}

/* ************************************************************************** */

void MobileUI::setScreenSecure(const bool value)
{
    const bool changed = (value != m_screenSecure);

    m_screenSecure = value;
    m_platform->setScreenSecure(value);

    if (changed) Q_EMIT screenUpdated();
}

/* ************************************************************************** */

void MobileUI::hapticFeedback(const MobileUI::HapticFeedback type)
{
    m_platform->triggerHapticFeedback(type);
}
void MobileUI::vibrate(const MobileUI::HapticFeedback type)
{
    m_platform->triggerHapticFeedback(type);
}

/* ************************************************************************** */

void MobileUI::refreshTorch()
{
    const int torch = m_platform->getTorch();
    if (torch < 0) return; // could not be read, keep the current one

    if ((torch == 1) != m_torchEnabled)
    {
        m_torchEnabled = (torch == 1);
        Q_EMIT torchUpdated();
    }
}

void MobileUI::setTorchEnabled(const bool on)
{
    if (m_platform->setTorch(on))
    {
        if (on != m_torchEnabled)
        {
            m_torchEnabled = on;
            Q_EMIT torchUpdated();
        }
    }
}

/* ************************************************************************** */

void MobileUI::backToHomeScreen()
{
    m_platform->backToHomeScreen();
}

/* ************************************************************************** */

double MobileUI::colorLuminance(const QColor &color)
{
    return (0.299 * color.red() + 0.587 * color.green() + 0.114 * color.blue()) / 255.0;
}

bool MobileUI::isColorLight_android(const QColor &color)
{
    return colorLuminance(color) > 0.8;
}

bool MobileUI::isColorLight_hyperos(const QColor &color)
{
    return colorLuminance(color) > 0.5;
}

/* ************************************************************************** */
