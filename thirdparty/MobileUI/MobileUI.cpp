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
#include <QQmlEngine>
#include <QScreen>
#include <QWindow>
#include <QTimer>
#include <QDebug>

#include <cmath>

/* ************************************************************************** */

MobileUI *MobileUI::instance = nullptr;

MobileUI *MobileUI::getInstance()
{
    if (instance == nullptr)
    {
        instance = new MobileUI();
        QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    }

    return instance;
}

MobileUI *MobileUI::create(QQmlEngine *, QJSEngine *)
{
    return MobileUI::getInstance();
}

/* ************************************************************************** */

MobileUI::MobileUI(QObject *parent) : QObject(parent), d(std::make_unique<MobileUIPrivate>())
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    QScreen *screen = qApp->primaryScreen();
    if (screen)
    {
        double screenSizeInch = std::sqrt(std::pow(screen->physicalSize().width(), 2.0) +
                                          std::pow(screen->physicalSize().height(), 2.0)) / (2.54 * 10.0);

        if (screenSizeInch >= 7.0) m_isTablet = true;
        else  m_isPhone = true;
    }

    // The application window doesn't exist yet when this object is created from
    // QML, so defer the signal hookup and the first safe area computation until
    // the event loop is running. connectSignals() must be called only ONCE.
    QTimer::singleShot(0, this, [this]() {
        connectSignals();

        refreshSystemBars();
        refreshSafeAreas();
        getDeviceTheme();
    });
#endif
}

MobileUI::~MobileUI() = default;

/* ************************************************************************** */

void MobileUI::connectSignals()
{
    QScreen *screen = qApp->primaryScreen();
    if (screen)
    {
        QObject::connect(screen, &QScreen::orientationChanged,
                         this, [this](Qt::ScreenOrientation) { refreshMobileUI(); });
    }

    const QWindowList windows = qApp->allWindows();
    QWindow *window = windows.isEmpty() ? nullptr : windows.first();
    if (window)
    {
        QObject::connect(window, &QWindow::visibilityChanged,
                         this, [this](QWindow::Visibility) { refreshMobileUI(); });
    }

    // The OS may reset the native system bar styles/colors when the application
    // returns to the foreground, so we re-apply them when becoming active again.
    QObject::connect(qApp, &QGuiApplication::applicationStateChanged,
                     this, [this](Qt::ApplicationState state) { if (state == Qt::ApplicationActive) refreshSafeAreas(); });

    // A light/dark mode change does not emit orientationChanged/visibilityChanged,
    // so make sure we re-apply our settings.
    if (QStyleHints *hints = qApp->styleHints())
    {
        QObject::connect(hints, &QStyleHints::colorSchemeChanged,
                         this, [this](Qt::ColorScheme) { refreshMobileUI(); getDeviceTheme(); Q_EMIT devicethemeUpdated(); });
    }
}

/* ************************************************************************** */

void MobileUI::refreshMobileUI()
{
    // Re-apply the native bar colors / themes (lost on rotation or resume)
    refreshSystemBars();

    // Re-compute safe areas (changed on rotation)
    refreshSafeAreas();

    // After an orientation or visibility change the native insets and bar sizes are not always settled immediately,
    // so re-read them a few times with increasing delays until they stabilize.
    for (int delay : {66, 256, 512, 1024})
    {
        QTimer::singleShot(delay, this, [this]() { refreshSystemBars(); refreshSafeAreas(); });
    }
}

/* ************************************************************************** */

MobileUI::Theme MobileUI::getDeviceTheme()
{
    return static_cast<MobileUI::Theme>(d->getDeviceTheme());
}

/* ************************************************************************** */

QColor MobileUI::getStatusbarColor() const
{
    return m_statusbarColor;
}

void MobileUI::setStatusbarColor(const QColor &color)
{
    if (!color.isValid()) return;

    m_statusbarColor = color;
    d->setColor_statusbar(color);

    //qDebug() << "MobileUI::setStatusbarColor(" << color.name() << ") luminance:" << colorLuminance(color);

    // Automatically derive a theme from the underlying color
    // If transparent, that responsability is best left to the user
    if (color.alpha() > 0)
    {
        const MobileUI::Theme theme = static_cast<MobileUI::Theme>(!isColorLight_android(color));
        if (theme != m_statusbarTheme)
        {
            m_statusbarTheme = theme;
            d->setTheme_statusbar(theme);
        }
    }
}

MobileUI::Theme MobileUI::getStatusbarTheme() const
{
    return m_statusbarTheme;
}

void MobileUI::setStatusbarTheme(const MobileUI::Theme theme)
{
    m_statusbarTheme = theme;
    d->setTheme_statusbar(theme);
}

/* ************************************************************************** */

QColor MobileUI::getNavbarColor() const
{
    return m_navbarColor;
}

void MobileUI::setNavbarColor(const QColor &color)
{
    if (!color.isValid()) return;

    m_navbarColor = color;
    d->setColor_navbar(color);

    //qDebug() << "MobileUI::setNavbarColor(" << color.name() << ") luminance:" << colorLuminance(color);

    // Automatically derive a theme from the underlying color
    // If transparent, that responsability is best left to the user
    if (color.alpha() > 0)
    {
        const MobileUI::Theme theme = static_cast<MobileUI::Theme>(!isColorLight_android(color));
        if (theme != m_navbarTheme)
        {
            m_navbarTheme = theme;
            d->setTheme_navbar(theme);
        }
    }
}

MobileUI::Theme MobileUI::getNavbarTheme() const
{
    return m_navbarTheme;
}

void MobileUI::setNavbarTheme(const MobileUI::Theme theme)
{
    m_navbarTheme = theme;
    d->setTheme_navbar(theme);
}

/* ************************************************************************** */

void MobileUI::refreshSystemBars()
{
    if (m_statusbarColor.isValid())
        d->setColor_statusbar(m_statusbarColor);

    if (m_navbarColor.isValid())
        d->setColor_navbar(m_navbarColor);

    d->setTheme_statusbar(m_statusbarTheme);
    d->setTheme_navbar(m_navbarTheme);
}

/* ************************************************************************** */

void MobileUI::refreshSafeAreas()
{
    int statusbar = d->getStatusbarHeight();
    int navbar = d->getNavbarHeight();
    int top = 0;
    int left = 0;
    int right = 0;
    int bottom = 0;

    const QWindowList windows = qApp->allWindows();
    QWindow *window = windows.isEmpty() ? nullptr : windows.first();

    const bool fullscreenMode = (window && window->visibility() == QWindow::FullScreen);

#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
    const bool maximizedHint = (window && (window->flags() & Qt::ExpandedClientAreaHint));
#else
    const bool maximizedHint = (window && (window->flags() & Qt::MaximizeUsingFullscreenGeometryHint));
#endif

    // Safe areas
    top = d->getSafeAreaTop();
    left = d->getSafeAreaLeft();
    right = d->getSafeAreaRight();
    bottom = d->getSafeAreaBottom();

    // When the window is in full screen mode, the system bars are no shown
    if (fullscreenMode)
    {
        statusbar = 0;
        navbar = 0;
    }

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

MobileUI::ScreenOrientation MobileUI::getScreenOrientation() const
{
    return m_screenOrientation;
}

void MobileUI::setScreenOrientation(const MobileUI::ScreenOrientation orientation)
{
    m_screenOrientation = orientation;
    d->setScreenOrientation(orientation);

    // Forcing the screen orientation does not emit QScreen::orientationChanged,
    // so we refresh the safe areas ourselves
    refreshMobileUI();
}

bool MobileUI::getScreenAlwaysOn() const
{
    return m_screenAlwaysOn;
}

void MobileUI::setScreenAlwaysOn(const bool value)
{
    m_screenAlwaysOn = value;
    d->setScreenAlwaysOn(value);
}

/* ************************************************************************** */

int MobileUI::getScreenBrightness()
{
    return d->getScreenBrightness();
}

void MobileUI::setScreenBrightness(const int value)
{
    d->setScreenBrightness(value);
}

/* ************************************************************************** */

void MobileUI::vibrate()
{
    d->vibrate();
}

void MobileUI::backToHomeScreen()
{
    d->backToHomeScreen();
}

/* ************************************************************************** */

double MobileUI::colorLuminance(const QColor &color)
{
    return (0.299 * color.red() + 0.587 * color.green() + 0.114 * color.blue()) / 255.0;
}

bool MobileUI::isColorLight_android(const QColor &color)
{
    return colorLuminance(color) > 0.66;
}

bool MobileUI::isColorLight_hyperos(const QColor &color)
{
    return colorLuminance(color) > 0.5;
}

/* ************************************************************************** */
