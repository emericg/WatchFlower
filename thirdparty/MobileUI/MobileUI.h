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

#ifndef MOBILEUI_H
#define MOBILEUI_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QColor>

#include <memory>

class QQmlEngine;
class QJSEngine;
class MobileUIPrivate;

/* ************************************************************************** */

class MobileUI : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool isPhone READ isDevicePhone CONSTANT)
    Q_PROPERTY(bool isTablet READ isDeviceTablet CONSTANT)

    Q_PROPERTY(Theme deviceTheme READ getDeviceTheme NOTIFY devicethemeUpdated)

    Q_PROPERTY(QColor statusbarColor READ getStatusbarColor WRITE setStatusbarColor NOTIFY statusbarUpdated)
    Q_PROPERTY(Theme statusbarTheme READ getStatusbarTheme WRITE setStatusbarTheme NOTIFY statusbarUpdated)
    Q_PROPERTY(int statusbarHeight READ getStatusbarHeight NOTIFY safeAreaUpdated)

    Q_PROPERTY(QColor navbarColor READ getNavbarColor WRITE setNavbarColor NOTIFY navbarUpdated)
    Q_PROPERTY(Theme navbarTheme READ getNavbarTheme WRITE setNavbarTheme NOTIFY navbarUpdated)
    Q_PROPERTY(int navbarHeight READ getNavbarHeight NOTIFY safeAreaUpdated)

    Q_PROPERTY(int safeAreaTop READ getSafeAreaTop NOTIFY safeAreaUpdated)
    Q_PROPERTY(int safeAreaLeft READ getSafeAreaLeft NOTIFY safeAreaUpdated)
    Q_PROPERTY(int safeAreaRight READ getSafeAreaRight NOTIFY safeAreaUpdated)
    Q_PROPERTY(int safeAreaBottom READ getSafeAreaBottom NOTIFY safeAreaUpdated)

    Q_PROPERTY(bool screenAlwaysOn READ getScreenAlwaysOn WRITE setScreenAlwaysOn NOTIFY screenUpdated)
    Q_PROPERTY(ScreenOrientation screenOrientation READ getScreenOrientation WRITE setScreenOrientation NOTIFY screenUpdated)
    Q_PROPERTY(int screenBrightness READ getScreenBrightness WRITE setScreenBrightness NOTIFY screenUpdated)

public:
    enum Theme {
        Light,  //!< Light application theme, usually light background and dark texts.
        Dark    //!< Dark application theme, usually dark background and light texts.
    };
    Q_ENUM(Theme)

    enum ScreenOrientation {
        Unlocked = 0,

        Portrait            = (1 << 0),
        Portrait_upsidedown = (1 << 1),
        Portrait_sensor     = (1 << 2),

        Landscape_left      = (1 << 3),
        Landscape_right     = (1 << 4),
        Landscape_sensor    = (1 << 5),
    };
    Q_ENUM(ScreenOrientation)

Q_SIGNALS:
    void devicethemeUpdated();
    void statusbarUpdated();
    void navbarUpdated();
    void safeAreaUpdated();
    void screenUpdated();

public:
    /*!
     * \brief Get the process-wide MobileUI singleton instance.
     *
     * Use this to access the instance (and its cached safe area properties /
     * signals) from C++. The same instance is shared with QML.
     */
    static MobileUI *getInstance();

    /*!
     * \brief QML singleton factory.
     *
     * Called by the QML engine to obtain the MobileUI singleton. It simply
     * returns getInstance(), so C++ and QML share a single instance.
     */
    static MobileUI *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    /*!
     * \brief Refresh UI themes/colors and recompute system bar sizes and screen safe areas.
     *
     * This is called automatically whenever the screen orientation or the window
     * visibility changes, so the exposed properties stay up to date on their own.
     */
    Q_INVOKABLE void refreshMobileUI();

    // Device type /////////////////////////////////////////////////////////////

    bool isDevicePhone() const { return m_isPhone; }
    bool isDeviceTablet() const { return m_isTablet; }

    // Device theme ////////////////////////////////////////////////////////////

    /*!
     * \brief Get the theme currently in effect on this device.
     * \return see MobileUI::Theme enum.
     */
    MobileUI::Theme getDeviceTheme();

    // System bars /////////////////////////////////////////////////////////////

    // Status bar
    QColor getStatusbarColor() const;
    void setStatusbarColor(const QColor &color);

    MobileUI::Theme getStatusbarTheme() const;
    void setStatusbarTheme(const MobileUI::Theme theme);

    // Navigation bar
    QColor getNavbarColor() const;
    void setNavbarColor(const QColor &color);

    MobileUI::Theme getNavbarTheme() const;
    void setNavbarTheme(const MobileUI::Theme theme);

    /*!
     * \brief Refresh UI statusbar/navigationbar themes/colors.
     */
    Q_INVOKABLE void refreshSystemBars();

    // Screen safe areas ///////////////////////////////////////////////////////

    int getStatusbarHeight() const { return m_statusbarHeight; }
    int getNavbarHeight() const { return m_navbarHeight; }

    int getSafeAreaTop() const { return m_safeAreaTop; }
    int getSafeAreaLeft() const { return m_safeAreaLeft; }
    int getSafeAreaRight() const { return m_safeAreaRight; }
    int getSafeAreaBottom() const { return m_safeAreaBottom; }

    /*!
     * \brief Recompute system bar sizes and screen safe areas.
     *
     * This is called automatically whenever the screen orientation or the window
     * visibility changes, so the exposed properties stay up to date on their own.
     */
    Q_INVOKABLE void refreshSafeAreas();

    // Screen helpers //////////////////////////////////////////////////////////

    /*!
     * \brief Get orientation lock (if set).
     * \return See MobileUI::ScreenOrientation enum.
     */
    MobileUI::ScreenOrientation getScreenOrientation() const;

    /*!
     * \brief Orientation locker.
     * \param orientation: see MobileUI::ScreenOrientation enum.
     * \note Portrait_sensor and Landscape_sensor aren't available on iOS.
     *
     * You can also achieve similar functionality through application manifest or plist:
     * - https://developer.android.com/guide/topics/manifest/activity-element.html#screen
     * - https://developer.apple.com/documentation/bundleresources/information_property_list/uisupportedinterfaceorientations
     */
    Q_INVOKABLE void setScreenOrientation(const MobileUI::ScreenOrientation orientation);

    /*!
     * \brief Get screensaver lock (if set).
     * \return on or off.
     */
    bool getScreenAlwaysOn() const;

    /*!
     * \brief Lock screensaver.
     * \param value: on or off.
     */
    Q_INVOKABLE void setScreenAlwaysOn(const bool value);

    /*!
     * \brief Get screen brightness set for the current app (on Android) or system wide (on iOS).
     * \return screen brightness, from 0 to 100.
     *
     * If brightness has not been set for the current app, this function will
     * return the OS wide brightness level.
     */
    int getScreenBrightness();

    /*!
     * \brief Set screen brightness for the current app (on Android) or system wide (on iOS).
     * \param value: screen brightness, from 0 to 100.
     */
    Q_INVOKABLE void setScreenBrightness(const int value);

    // Other helpers ///////////////////////////////////////////////////////////

    /*!
     * \brief Trigger an haptic feedback.
     * \note iPads don't support haptic feedbacks.
     * \note On Android the "android.permission.VIBRATE" must be added to the manifest.
     */
    Q_INVOKABLE void vibrate();

    /*!
     * \brief Go back to Android home screen.
     *
     * You can use this method to bypass the default behavior for the Android
     * back button, which is to kill the application instead of doing what every
     * single Android application does, going back to the home screen...
     */
    Q_INVOKABLE void backToHomeScreen();

    // Other helpers ///////////////////////////////////////////////////////////

    //! Perceived luminance (Rec. 601), normalized to the [0.0 ; 1.0] range.
    static double colorLuminance(const QColor &color);

    //! Tell whether a color is perceived as "light".
    static bool isColorLight_android(const QColor &color);
    static bool isColorLight_hyperos(const QColor &color);

private:
    // Device types
    bool m_isPhone = false;
    bool m_isTablet = false;

    // OS theme
    MobileUI::Theme m_osTheme = MobileUI::Light;

    // System bars states
    QColor m_statusbarColor;
    MobileUI::Theme m_statusbarTheme = MobileUI::Light;

    QColor m_navbarColor;
    MobileUI::Theme m_navbarTheme = MobileUI::Light;

    int m_statusbarHeight = 0;
    int m_navbarHeight = 0;

    // Screen safe areas
    int m_safeAreaTop = 0;
    int m_safeAreaLeft = 0;
    int m_safeAreaRight = 0;
    int m_safeAreaBottom = 0;

    // Screen states
    bool m_screenAlwaysOn = false;
    MobileUI::ScreenOrientation m_screenOrientation = MobileUI::Unlocked;

    //! Connect to screen orientation and window visibility changes.
    void connectSignals();

    //! Per-platform backend.
    std::unique_ptr<MobileUIPrivate> d;

    // Singleton
    static MobileUI *instance;
    explicit MobileUI(QObject *parent = nullptr);
    ~MobileUI() override;
};

/* ************************************************************************** */
#endif // MOBILEUI_H
