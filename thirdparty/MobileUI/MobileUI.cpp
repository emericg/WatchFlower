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
#include "MobileUI_private.h"

#include <QGuiApplication>
#include <QStyleHints>
#include <QInputMethod>
#include <QQmlEngine>
#include <QScreen>
#include <QWindow>
#include <QTimer>
#include <QDebug>

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
    d = std::make_unique<MobileUIPrivate>();

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    // Track the on-screen keyboard height through Qt's input method (cross-platform).
    if (QInputMethod *im = qApp->inputMethod())
    {
        connect(im, &QInputMethod::keyboardRectangleChanged, this, &MobileUI::refreshKeyboardHeight);
        connect(im, &QInputMethod::visibleChanged, this, &MobileUI::refreshKeyboardHeight);
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
        double screenSizeInch = std::sqrt(std::pow(screen->physicalSize().width(), 2.0) +
                                          std::pow(screen->physicalSize().height(), 2.0)) / (2.54 * 10.0);

        if (screenSizeInch >= 7.0) m_isTablet = true;
        else m_isPhone = true;
    }

    // The application window doesn't exist yet when this object is created from QML,
    // so we defer the signal hookup and the first safe area computation until the event loop is running.
    QTimer::singleShot(0, this, [this]() {
        // connectSignals() must be called only ONCE
        connectSignals();

        refreshSystemBars();
        refreshSafeAreas();
        refreshDeviceTheme();
    });
#endif
}

MobileUI::~MobileUI() = default;

/* ************************************************************************** */

void MobileUI::connectSignals()
{
    // When orientation changes, we need to at least recompute the safe areas.

    QScreen *screen = qApp->primaryScreen();
    if (screen)
    {
        QObject::connect(screen, &QScreen::orientationChanged,
                         this, [this](Qt::ScreenOrientation) { refreshMobileUI(); });
    }

    // The OS may reset the native system bar styles/colors when the application
    // returns to the foreground, so we re-apply them when becoming active again.

    const QWindowList windows = qApp->allWindows();
    QWindow *window = windows.isEmpty() ? nullptr : windows.first();
    if (window)
    {
        QObject::connect(window, &QWindow::visibilityChanged,
                         this, [this](QWindow::Visibility) { refreshMobileUI(); });
    }

    QObject::connect(qApp, &QGuiApplication::applicationStateChanged,
                     this, [this](Qt::ApplicationState state) { if (state == Qt::ApplicationActive) refreshMobileUI(); });

    // A light/dark mode change does not emit orientationChanged/visibilityChanged,
    // so make sure we re-apply our settings.

    if (QStyleHints *hints = qApp->styleHints())
    {
        QObject::connect(hints, &QStyleHints::colorSchemeChanged,
                         this, [this](Qt::ColorScheme) { refreshMobileUI(); refreshDeviceTheme(); });
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
    const MobileUI::Theme theme = static_cast<MobileUI::Theme>(d->getDeviceTheme());
    if (theme != m_osTheme)
    {
        m_osTheme = theme;
        Q_EMIT devicethemeUpdated();
    }
}

/* ************************************************************************** */

void MobileUI::refreshSystemBars()
{
    // colors
    if (m_statusbarColor.isValid()) d->setColor_statusbar(m_statusbarColor);
    if (m_navbarColor.isValid()) d->setColor_navbar(m_navbarColor);

    // themes
    if (m_statusbarTheme > MobileUI::Auto) d->setTheme_statusbar(m_statusbarTheme);
    else if (m_statusbarThemeSet > MobileUI::Auto) d->setTheme_statusbar(m_statusbarThemeSet);
    if (m_navbarTheme > MobileUI::Auto) d->setTheme_navbar(m_navbarTheme);
    else if (m_navbarThemeSet > MobileUI::Auto) d->setTheme_navbar(m_navbarThemeSet);
}

/* ************************************************************************** */

QColor MobileUI::getStatusbarColor() const
{
    return m_statusbarColor;
}

void MobileUI::setStatusbarColor(const QColor &color)
{
    //qDebug() << "MobileUI::setStatusbarColor(" << color.name() << ") luminance:" << colorLuminance(color);
    if (!color.isValid()) return;

    const bool changed = (m_statusbarColor != color);

    // Re-apply anyway, and battle with the OS fighting us...
    m_statusbarColor = color;
    d->setColor_statusbar(color);

    // In "auto" mode, the theme follows the reference color, so re-resolve it.
    setStatusbarTheme_fromColor_refresh();

    if (changed) Q_EMIT statusbarUpdated();
}

QColor MobileUI::getStatusbarContentColor() const
{
    return m_statusbarContentColor;
}

void MobileUI::setStatusbarContentColor(const QColor &color)
{
    const bool changed = (m_statusbarContentColor != color);

    m_statusbarContentColor = color;

    // In "auto" mode, the theme follows the reference color, so re-resolve it.
    setStatusbarTheme_fromColor_refresh();

    if (changed) Q_EMIT statusbarUpdated();
}

MobileUI::Theme MobileUI::getStatusbarTheme() const
{
    return m_statusbarTheme;
}
MobileUI::Theme MobileUI::getStatusbarThemeSet() const
{
    if (m_statusbarTheme > MobileUI::Auto) return m_statusbarTheme;
    if (m_statusbarThemeSet > MobileUI::Auto) return m_statusbarThemeSet;
    return MobileUI::Auto;
}

void MobileUI::setStatusbarTheme(const MobileUI::Theme theme)
{
    bool changed = (theme != m_statusbarTheme);
    if (!changed) changed = (theme != m_statusbarThemeSet);

    if (theme > MobileUI::Auto)
    {
        m_statusbarTheme = m_statusbarThemeSet = theme;

        // Set & apply the new theme
        d->setTheme_statusbar(m_statusbarTheme);
    }
    else // if (theme == MobileUI::Auto)
    {
        m_statusbarTheme = m_statusbarThemeSet = MobileUI::Auto;

        // Derive & apply a new theme from the reference color, if possible
        setStatusbarTheme_fromColor_refresh();
    }

    if (changed) Q_EMIT statusbarUpdated();
}

MobileUI::Theme MobileUI::deriveStatusbarTheme(const QColor &color) const
{
    if (m_statusbarTheme == MobileUI::Auto)
    {
        if (color.isValid() && color.alpha() > 0)
        {
            return static_cast<MobileUI::Theme>(!isColorLight_android(color));
        }
    }

    return MobileUI::Auto;
}

void MobileUI::setStatusbarTheme_fromColor(const QColor &color)
{
    if (m_statusbarTheme != MobileUI::Auto) return;

   MobileUI::Theme theme = deriveStatusbarTheme(color);

    if (theme > MobileUI::Auto && theme != m_statusbarThemeSet)
    {
        m_statusbarThemeSet = theme;
        d->setTheme_statusbar(m_statusbarThemeSet);
        Q_EMIT statusbarUpdated();
    }
}

void MobileUI::setStatusbarTheme_fromColor_refresh()
{
    if (m_statusbarTheme != MobileUI::Auto) return;

    if (m_statusbarContentColor.isValid() && m_statusbarContentColor.alpha() > 0)
    {
        setStatusbarTheme_fromColor(m_statusbarContentColor);
    }
    else if (m_statusbarColor.isValid() && m_statusbarColor.alpha() > 0)
    {
        setStatusbarTheme_fromColor(m_statusbarColor);
    }
    else
    {
        // No usable reference color (transparent bar, no content color): fall back to a deterministic default
        if (m_osTheme != m_statusbarThemeSet)
        {
            m_statusbarThemeSet = m_osTheme;
            d->setTheme_statusbar(m_statusbarThemeSet);
            Q_EMIT statusbarUpdated();
        }
    }
}

/* ************************************************************************** */

QColor MobileUI::getNavbarColor() const
{
    return m_navbarColor;
}

void MobileUI::setNavbarColor(const QColor &color)
{
    //qDebug() << "MobileUI::setNavbarColor(" << color.name() << ") luminance:" << colorLuminance(color);
    if (!color.isValid()) return;

    const bool changed = (m_navbarColor != color);

    // We re-apply anyway, and battle with the OS fighting us...
    m_navbarColor = color;
    d->setColor_navbar(color);

    // In "auto" mode, the theme follows the reference color, so re-resolve it.
    setNavbarTheme_fromColor_refresh();

    if (changed) Q_EMIT navbarUpdated();
}

QColor MobileUI::getNavbarContentColor() const
{
    return m_navbarContentColor;
}

void MobileUI::setNavbarContentColor(const QColor &color)
{
    const bool changed = (m_navbarContentColor != color);

    m_navbarContentColor = color;

    // In "auto" mode, the theme follows the reference color, so re-resolve it.
    setNavbarTheme_fromColor_refresh();

    if (changed) Q_EMIT navbarUpdated();
}

MobileUI::Theme MobileUI::getNavbarTheme() const
{
    return m_navbarTheme;
}
MobileUI::Theme MobileUI::getNavbarThemeSet() const
{
    if (m_navbarTheme > MobileUI::Auto) return m_navbarTheme;
    if (m_navbarThemeSet > MobileUI::Auto) return m_navbarThemeSet;
    return MobileUI::Auto;
}

void MobileUI::setNavbarTheme(const MobileUI::Theme theme)
{
    bool changed = (theme != m_navbarTheme);
    if (!changed) changed = (theme != m_navbarThemeSet);

    if (theme > MobileUI::Auto)
    {
        m_navbarTheme = m_navbarThemeSet = theme;

        // Set & apply the new theme
        d->setTheme_navbar(m_navbarTheme);
    }
    else // if (theme == MobileUI::Auto)
    {
        m_navbarTheme = m_navbarThemeSet = MobileUI::Auto;

        // Derive & apply a new theme from the reference color, if possible
        setNavbarTheme_fromColor_refresh();
    }

    if (changed) Q_EMIT navbarUpdated();
}

MobileUI::Theme MobileUI::deriveNavbarTheme(const QColor &color) const
{
    if (m_navbarTheme == MobileUI::Auto)
    {
        if (color.isValid() && color.alpha() > 0)
        {
            return static_cast<MobileUI::Theme>(!isColorLight_android(color));
        }
    }

    return MobileUI::Auto;
}

void MobileUI::setNavbarTheme_fromColor(const QColor &color)
{
    if (m_navbarTheme != MobileUI::Auto) return;

    const MobileUI::Theme theme = deriveNavbarTheme(color);

    if (theme > MobileUI::Auto && theme != m_navbarThemeSet)
    {
        m_navbarThemeSet = theme;
        d->setTheme_navbar(m_navbarThemeSet);
        Q_EMIT navbarUpdated();
    }
}

void MobileUI::setNavbarTheme_fromColor_refresh()
{
    if (m_navbarTheme != MobileUI::Auto) return;

    if (m_navbarContentColor.isValid() && m_navbarContentColor.alpha() > 0)
    {
        setNavbarTheme_fromColor(m_navbarContentColor);
    }
    else if (m_navbarColor.isValid() && m_navbarColor.alpha() > 0)
    {
        setNavbarTheme_fromColor(m_navbarColor);
    }
    else
    {
        // no usable reference color (transparent bar, no content color): fall back to a deterministic default
        if (m_osTheme != m_navbarThemeSet)
        {
            m_navbarThemeSet = m_osTheme;
            d->setTheme_navbar(m_navbarThemeSet);
            Q_EMIT navbarUpdated();
        }
    }
}

/* ************************************************************************** */

void MobileUI::refreshSafeAreas()
{
    int statusbar = 0, navbar = 0, top = 0, left = 0, right = 0, bottom = 0;
    d->getSafeAreaMetrics(statusbar, navbar, top, left, right, bottom);

    const QWindowList windows = qApp->allWindows();
    QWindow *window = windows.isEmpty() ? nullptr : windows.first();
    const bool fullscreenMode = (window && window->visibility() == QWindow::FullScreen);

    // When the window is in "full screen" mode, the system bars are not shown
    if (fullscreenMode)
    {
        statusbar = 0;
        navbar = 0;
    }

    // iOS without "maximized geometry" has no available safe areas
#if defined (Q_OS_IOS)
#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
    const bool maximizedHint = (window && (window->flags() & Qt::ExpandedClientAreaHint));
#else
    const bool maximizedHint = (window && (window->flags() & Qt::MaximizeUsingFullscreenGeometryHint));
#endif

    if (!maximizedHint)
    {
        statusbar = 0;
        navbar = 0;
        top = 0;
        left = 0;
        right = 0;
        bottom = 0;
    }
#endif

    // Notify the UI safeAreas have changed, if needed
    if (statusbar != m_statusbarHeight || navbar != m_navbarHeight ||
        top != m_safeAreaTop || left != m_safeAreaLeft ||
        right != m_safeAreaRight || bottom != m_safeAreaBottom)
    {
        m_statusbarHeight = statusbar;
        m_navbarHeight = navbar;
        m_safeAreaTop = top;
        m_safeAreaLeft = left;
        m_safeAreaRight = right;
        m_safeAreaBottom = bottom;

        Q_EMIT safeAreaUpdated();
    }
}

/* ************************************************************************** */

void MobileUI::refreshKeyboardHeight()
{
    // Important caveat:
    // This is driven by Qt's input-method signals (keyboardRectangleChanged / visibleChanged)
    // Implementing a real WindowInsets(Animation) native listener on Android requires
    // a Java/Kotlin helper class, which is... Too heavy...
    // In practice Qt fires these signals when the keyboard shows/hides, which is
    // enough for everything except tracking the keyboard's slide-in/out per frame animation.

    int height = d->getKeyboardHeight();
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

int MobileUI::getScreenBrightness()
{
    return d->getScreenBrightness();
}

void MobileUI::setScreenBrightness(const int value)
{
    const bool changed = (value != m_screenBrightness);

    // We re-apply, the OS might have changed that on its own
    m_screenBrightness = value;
    d->setScreenBrightness(value);

    if (changed) Q_EMIT screenUpdated();
}

/* ************************************************************************** */

MobileUI::ScreenLockOrientation MobileUI::getScreenLockOrientation() const
{
    return m_screenOrientation;
}

void MobileUI::setScreenLockOrientation(const MobileUI::ScreenLockOrientation orientation)
{
    const bool changed = (orientation != m_screenOrientation);

    // We re-apply, the OS might have changed that on its own
    m_screenOrientation = orientation;
    d->setScreenLockOrientation(orientation);

    // Forcing the screen orientation does not emit QScreen::orientationChanged,
    // so we refresh the safe areas ourselves
    refreshMobileUI();

    if (changed) Q_EMIT screenUpdated();
}

/* ************************************************************************** */

bool MobileUI::getScreenAlwaysOn() const
{
    return m_screenAlwaysOn;
}

void MobileUI::setScreenAlwaysOn(const bool value)
{
    const bool changed = (value != m_screenAlwaysOn);

    // We re-apply, the OS might have changed that on its own
    m_screenAlwaysOn = value;
    d->setScreenAlwaysOn(value);

    if (changed) Q_EMIT screenUpdated();
}

/* ************************************************************************** */

void MobileUI::setHighRefreshRate(const bool value)
{
    const bool changed = (value != m_screenHighRefreshRate);

    m_screenHighRefreshRate = value;
    d->setHighRefreshRate(value);

    if (changed) Q_EMIT screenUpdated();
}

/* ************************************************************************** */

void MobileUI::setScreenSecure(const bool value)
{
    const bool changed = (value != m_screenSecure);

    m_screenSecure = value;
    d->setScreenSecure(value);

    if (changed) Q_EMIT screenUpdated();
}

/* ************************************************************************** */

void MobileUI::hapticFeedback(const MobileUI::HapticFeedback type)
{
    d->triggerHapticFeedback(type);
}
void MobileUI::vibrate(const MobileUI::HapticFeedback type)
{
    d->triggerHapticFeedback(type);
}

/* ************************************************************************** */

void MobileUI::setTorchEnabled(const bool on)
{
    // setTorch() returns the resulting state, which may differ from the request
    const bool result = d->setTorch(on);

    if (result != m_torchEnabled)
    {
        m_torchEnabled = result;
        Q_EMIT torchUpdated();
    }
}

/* ************************************************************************** */

void MobileUI::backToHomeScreen()
{
    d->backToHomeScreen();
}

/* ************************************************************************** */

void MobileUI::setIconBadgeNumber(const int number)
{
    const int badge = (number > 0) ? number : 0;

    if (m_iconBadgeNumber != badge)
    {
        m_iconBadgeNumber = badge;
        d->setIconBadgeNumber(badge);

        Q_EMIT iconBadgeUpdated();
    }
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
