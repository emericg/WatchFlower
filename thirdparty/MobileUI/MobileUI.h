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
#include <QTimer>
#include <QList>

#include <tuple>

class QQmlEngine;
class QJSEngine;
class QScreen;

class PlatformMobileUI;

/* ************************************************************************** */

/*!
 * \brief Mobile platform UI integration singleton.
 *
 * MobileUI lets a QML (or C++) application interact with mobile specific
 * features that have no equivalent in the standard Qt APIs:
 * - Android status bar and navigation bar colors and themes.
 * - iOS status bar theme (iOS has no status bar color, and no navigation bar).
 * - The device OS theme (light or dark mode).
 * - The screen safe areas (notches, cutouts, system bars, rounded corners).
 * - The on-screen keyboard height.
 * - Force screen orientation.
 * - Force screen brightness.
 * - Screensaver inhibition.
 * - Haptic feedbacks.
 * - Torch mode (rear camera flash LED).
 * - Android "secure screen" helper.
 * - Android "high refresh rate" helper.
 * - Android "back to home screen" helper.
 *
 * It is exposed to QML as a singleton, and the same instance is shared with C++
 * through getInstance(), so settings applied from either side stay consistent.
 *
 * You can use it without worries on desktop platforms, a dummy backend is used so
 * no code is runned, setters are ignored, getters return neutral/default values...
 * Except for the device theme, which follows the color scheme reported by Qt.
 *
 * \note Thread affinity: MobileUI must be used from the GUI (main) thread ONLY.
 */
class MobileUI : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool isPhone READ isDevicePhone CONSTANT FINAL)
    Q_PROPERTY(bool isTablet READ isDeviceTablet CONSTANT FINAL)

    Q_PROPERTY(Theme deviceTheme READ getDeviceTheme NOTIFY deviceThemeUpdated FINAL)

    Q_PROPERTY(bool systemBarColorsSupported READ getSystemBarColorsSupported CONSTANT FINAL)

    Q_PROPERTY(QColor statusbarColor READ getStatusbarColor WRITE setStatusbarColor NOTIFY statusbarUpdated FINAL)
    Q_PROPERTY(QColor statusbarContentColor READ getStatusbarContentColor WRITE setStatusbarContentColor NOTIFY statusbarUpdated FINAL)
    Q_PROPERTY(Theme statusbarTheme READ getStatusbarTheme WRITE setStatusbarTheme NOTIFY statusbarUpdated FINAL)
    Q_PROPERTY(Theme statusbarThemeSet READ getStatusbarThemeSet NOTIFY statusbarUpdated FINAL)

    Q_PROPERTY(QColor navbarColor READ getNavbarColor WRITE setNavbarColor NOTIFY navbarUpdated FINAL)
    Q_PROPERTY(QColor navbarContentColor READ getNavbarContentColor WRITE setNavbarContentColor NOTIFY navbarUpdated FINAL)
    Q_PROPERTY(Theme navbarTheme READ getNavbarTheme WRITE setNavbarTheme NOTIFY navbarUpdated FINAL)
    Q_PROPERTY(Theme navbarThemeSet READ getNavbarThemeSet NOTIFY navbarUpdated FINAL)

    Q_PROPERTY(int statusbarHeight READ getStatusbarHeight NOTIFY safeAreaUpdated FINAL)
    Q_PROPERTY(int navbarHeight READ getNavbarHeight NOTIFY safeAreaUpdated FINAL)
    Q_PROPERTY(int keyboardHeight READ getKeyboardHeight NOTIFY keyboardUpdated FINAL)

    Q_PROPERTY(int safeAreaTop READ getSafeAreaTop NOTIFY safeAreaUpdated FINAL)
    Q_PROPERTY(int safeAreaLeft READ getSafeAreaLeft NOTIFY safeAreaUpdated FINAL)
    Q_PROPERTY(int safeAreaRight READ getSafeAreaRight NOTIFY safeAreaUpdated FINAL)
    Q_PROPERTY(int safeAreaBottom READ getSafeAreaBottom NOTIFY safeAreaUpdated FINAL)

    Q_PROPERTY(ScreenLockOrientation screenLockOrientation READ getScreenLockOrientation WRITE setScreenLockOrientation NOTIFY screenUpdated FINAL)
    Q_PROPERTY(int screenBrightness READ getScreenBrightness WRITE setScreenBrightness NOTIFY brightnessUpdated FINAL)
    Q_PROPERTY(bool screenAlwaysOn READ getScreenAlwaysOn WRITE setScreenAlwaysOn NOTIFY screenUpdated FINAL)
    Q_PROPERTY(bool screenSecure READ getScreenSecure WRITE setScreenSecure NOTIFY screenUpdated FINAL)
    Q_PROPERTY(bool screenHighRefreshRate READ getScreenHighRefreshRate WRITE setScreenHighRefreshRate NOTIFY screenUpdated FINAL)

    Q_PROPERTY(bool torchEnabled READ getTorchEnabled WRITE setTorchEnabled NOTIFY torchUpdated FINAL)

Q_SIGNALS:
    void deviceThemeUpdated();      //!< Emitted when the device OS theme (light/dark mode) changes.
    void statusbarUpdated();        //!< Emitted when a status bar color or theme is set.
    void navbarUpdated();           //!< Emitted when a navigation bar color or theme is set.
    void keyboardUpdated();         //!< Emitted when the on-screen keyboard height changes (shown, hidden or resized).
    void safeAreaUpdated();         //!< Emitted when the system bar heights or the screen safe areas are changed (by a rotation or some other reason).
    void screenUpdated();           //!< Emitted when a screen related property (always-on, orientation, secure, refresh rate) is set.
    void brightnessUpdated();       //!< Emitted when the screen brightness is set.
    void torchUpdated();            //!< Emitted when the torch (camera flash LED) state changes.

public:
    /*!
     * \brief Get the process-wide MobileUI singleton instance.
     *
     * Use this to access the instance from C++.
     * The same instance is shared with QML.
     */
    static MobileUI *getInstance();

    /*!
     * \brief QML singleton factory.
     *
     * Called by the QML engine to obtain the MobileUI singleton.
     * Returns getInstance(), so C++ and QML share the same single instance,
     * and flags it C++ owned so the JS engine never deletes it.
     */
    static MobileUI *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    // Enums ///////////////////////////////////////////////////////////////////

    enum Theme {
        Auto  = -1, //!< Derive the bar theme from its reference color, or follow the device theme if none is set.
        Light =  0, //!< Light application theme, usually light background and dark texts.
        Dark  =  1, //!< Dark application theme, usually dark background and light texts.
    };
    Q_ENUM(Theme)

    // MobileUI ////////////////////////////////////////////////////////////////

    /*!
     * \brief Refresh UI themes/colors and recompute system bar sizes and screen safe areas.
     *
     * This is the main entry point, called automatically whenever the screen orientation,
     * window visibility or OS theme changes, so the exposed properties stay up to date on their own.
     *
     * You don't usually need to call this function manually, except after a change MobileUI
     * can't observe, like a window flags change (ex: Qt::MaximizeUsingFullscreenGeometryHint).
     * On desktop platforms, this is a no-op.
     */
    Q_INVOKABLE void refreshMobileUI();

    // Device type /////////////////////////////////////////////////////////////

    /*!
     * \brief Tell whether the application runs on a phone-sized device.
     * \return true on a phone, false otherwise.
     *
     * The classification is based on the physical screen diagonal computed at startup:
     * - A diagonal below 7 inches is considered a phone.
     * - On desktop platforms this returns false.
     */
    bool isDevicePhone() const { return m_isPhone; }

    /*!
     * \brief Tell whether the application runs on a tablet-sized device.
     * \return true on a tablet, false otherwise.
     *
     * The classification is based on the physical screen diagonal computed at startup:
     * - A diagonal of 7 inches or more is considered a tablet.
     * - On desktop platforms this returns false.
     */
    bool isDeviceTablet() const { return m_isTablet; }

    // Device theme ////////////////////////////////////////////////////////////

    /*!
     * \brief Get the theme currently in effect on this device.
     * \return MobileUI::Light or MobileUI::Dark, or MobileUI::Auto while unknown (not read / reported by the OS yet).
     *
     * The device theme is read asynchronously on mobile platforms, so it is MobileUI::Auto until the first read completes.
     */
    MobileUI::Theme getDeviceTheme() const { return m_osTheme; }

    // System bars /////////////////////////////////////////////////////////////

    /*!
     * \brief Tell whether the system bar background colors can be set.
     * \return true if setStatusbarColor() and setNavbarColor() have a visible effect.
     *
     * - On Android, false when edge-to-edge is enforced: on Android 15+ for applications
     *   targeting API level 35+, unless opted out (Android 15 only, see the
     *   windowOptOutEdgeToEdgeEnforcement theme attribute, ignored when targeting API level 36+).
     * - On iOS, always false (iOS has no notion of system bar colors).
     * - On desktop platforms, always false.
     *
     * When false, the application should paint its own content behind the system bars,
     * and use setStatusbarContentColor() / setNavbarContentColor() to drive their themes.
     * The value is computed once at startup.
     */
    bool getSystemBarColorsSupported() const { return m_systemBarColorsSupported; }

    // Status bar

    /*!
     * \brief Get the last status bar color that was set.
     * \return the current status bar color.
     * \note Android only (iOS has no notion of a status bar color).
     * \note This is the value previously passed to setStatusbarColor(), not a value read back from the OS.
     */
    QColor getStatusbarColor() const { return m_statusbar.color; }

    /*!
     * \brief Set the status bar background color.
     * \param color: the desired status bar color ("transparent" is ok, invalid colors are ignored).
     * \note Android only (iOS has no notion of a status bar color).
     * \note Ignored when getSystemBarColorsSupported() is false (ex: Android 15+ with edge-to-edge enforced),
     *       paint behind the bar instead, and use setStatusbarContentColor() to drive its theme.
     *
     * When the color is opaque and the status bar theme is set to Auto, a matching
     * Light/Dark theme is derived automatically from the color perceived luminance.
     * A translucent color is applied, but not used to derive the theme,
     * use setStatusbarContentColor() with the color the bar is actually shown over.
     */
    void setStatusbarColor(const QColor &color);

    //! Get the color used to derive the statusbarTheme (when theme is Auto).
    QColor getStatusbarContentColor() const { return m_statusbar.contentColor; }

    /*!
     * \brief Set a reference color used to derive the status bar theme, when in Auto mode.
     * \param color: the color the status bar icons should contrast against.
     *
     * Useful in edge-to-edge mode:
     * the OS bar is fully transparent (or not drawn at all) and your application
     * can paints freely its own content behind that bar, but the text/icon contrast
     * should still follow that painted color.
     *
     * When the color is opaque and the status bar theme is set to Auto, a matching
     * Light/Dark theme is derived automatically from the color perceived luminance.
     *
     * When an invalid or translucent color is set, Auto derivation falls back to statusbarColor,
     * and if that's not usable either, to the device theme. An invalid color also clears the content color.
     */
    void setStatusbarContentColor(const QColor &color);

    //! Get the current status bar theme we set manually.
    MobileUI::Theme getStatusbarTheme() const { return m_statusbar.theme; }

    //! Get the current status bar theme, set manually or derived automatically.
    MobileUI::Theme getStatusbarThemeSet() const { return m_statusbar.themeSet; }

    /*!
     * \brief Set the status bar foreground theme (icons/text contrast).
     * \param theme: see MobileUI::Theme enum (Light, Dark, or Auto).
     *
     * If Auto, the theme is derived from the reference color (content color first, then bar color),
     * or follows the device theme if none is usable.
     *
     * The OS may reset the theme on visibility/orientation changes, so MobileUI
     * re-applies it automatically.
     */
    void setStatusbarTheme(const MobileUI::Theme theme);

    // Navigation bar

    /*!
     * \brief Get the last navigation bar color that was set.
     * \return the current navigation bar color.
     * \note Android only.
     *
     * This is the value previously passed to setNavbarColor(), not a value read back from the OS.
     */
    QColor getNavbarColor() const { return m_navbar.color; }

    /*!
     * \brief Set the navigation bar background color.
     * \param color: the desired navigation bar color ("transparent" is ok, invalid colors are ignored).
     * \note Android only (iOS has no navigation bar).
     * \note Ignored when getSystemBarColorsSupported() is false (ex: Android 15+ with edge-to-edge enforced),
     *       paint behind the bar instead, and use setNavbarContentColor() to drive its theme.
     *
     * When the color is opaque and the navigation bar theme is set to Auto, a matching
     * Light/Dark theme is derived automatically from the color perceived luminance.
     * A translucent color is applied, but not used to derive the theme,
     * use setNavbarContentColor() with the color the bar is actually shown over.
     */
    void setNavbarColor(const QColor &color);

    //! Get the color used to derive the navbarTheme (when theme is Auto).
    QColor getNavbarContentColor() const { return m_navbar.contentColor; }

    /*!
     * \brief Set a reference color used to derive the navigation bar theme, when in Auto mode.
     * \param color: the color the navigation bar icons should contrast against.
     * \note Android only (iOS has no navigation bar).
     *
     * Useful in edge-to-edge mode:
     * the OS bar is fully transparent (or not drawn at all) and your application
     * can paints freely its own content behind that bar, but the text/icon contrast
     * should still follow that painted color.
     *
     * When the color is opaque and the navigation bar theme is set to Auto, a matching
     * Light/Dark theme is derived automatically from the color perceived luminance.
     *
     * When an invalid or translucent color is set, Auto derivation falls back to navbarColor,
     * and if that's not usable either, to the device theme. An invalid color also clears the content color.
     */
    void setNavbarContentColor(const QColor &color);

    //! Get the current navigation bar theme we set manually.
    MobileUI::Theme getNavbarTheme() const { return m_navbar.theme; }

    //! Get the current navigation bar theme, set manually or derived automatically.
    MobileUI::Theme getNavbarThemeSet() const { return m_navbar.themeSet; }

    /*!
     * \brief Set the navigation bar foreground theme (icons contrast).
     * \param theme: see MobileUI::Theme enum (Light, Dark, or Auto).
     * \note Android only (iOS has no navigation bar).
     *
     * If Auto, the theme is derived from the reference color (content color first, then bar color),
     * or follows the device theme if none is usable.
     *
     * The OS may reset the theme on visibility/orientation changes, so MobileUI
     * re-applies it automatically.
     */
    void setNavbarTheme(const MobileUI::Theme theme);

    // Screen safe areas ///////////////////////////////////////////////////////

    /*!
     * \brief System bar sizes and screen safe area insets, in device-independent pixels.
     */
    struct SafeAreaMetrics
    {
        int statusbarHeight = 0;
        int navbarHeight = 0;
        int top = 0;
        int left = 0;
        int right = 0;
        int bottom = 0;

        bool operator==(const SafeAreaMetrics &other) const
        {
            return std::tie(statusbarHeight, navbarHeight, top, left, right, bottom) ==
                   std::tie(other.statusbarHeight, other.navbarHeight, other.top, other.left, other.right, other.bottom);
        }
        bool operator!=(const SafeAreaMetrics &other) const { return !(*this == other); }
    };

    /*!
     * \brief Get the status bar height.
     * \return the status bar height in device-independent pixels, or 0 when it is not visible (full screen mode).
     *
     * The status bar is always at the top of the screen when visible.
     */
    int getStatusbarHeight() const { return m_safeAreas.statusbarHeight; }

    /*!
     * \brief Get the navigation bar height.
     * \return the navigation bar height in device-independent pixels, or 0 when it is not visible (full screen mode).
     *
     * The navigation bar is usually at the bottom of the screen. When the device
     * is rotated and the bar moves to the left/right edge, this returns 0 and
     * the bar size is instead accounted for in the left/right safe areas.
     */
    int getNavbarHeight() const { return m_safeAreas.navbarHeight; }

    /*!
     * \brief Get the top screen safe area inset.
     * \return the top inset in device-independent pixels.
     *
     * Integrates the status bar height when the status bar is visible.
     */
    int getSafeAreaTop() const { return m_safeAreas.top; }

    /*!
     * \brief Get the left screen safe area inset.
     * \return the left inset in device-independent pixels.
     */
    int getSafeAreaLeft() const { return m_safeAreas.left; }

    /*!
     * \brief Get the right screen safe area inset.
     * \return the right inset in device-independent pixels.
     */
    int getSafeAreaRight() const { return m_safeAreas.right; }

    /*!
     * \brief Get the bottom screen safe area inset.
     * \return the bottom inset in device-independent pixels.
     *
     * Integrates the navigation bar height when the navigation bar is visible
     * at the bottom of the screen.
     */
    int getSafeAreaBottom() const { return m_safeAreas.bottom; }

    // Screen helpers //////////////////////////////////////////////////////////

    /*!
     * \brief Screen orientations that can be locked through setScreenLockOrientation().
     *
     * These are used to *lock* the orientation,
     * they cannot be used to read the device's current physical orientation.
     */
    enum ScreenLockOrientation {
        Unlocked            = 0,    //!< Orientation is unlocked; the OS decides freely.
        Locked              = 1,    //!< Locked in the orientation in use when the lock is set.

        Portrait            = 2,    //!< Locked to portrait.
        Portrait_upsidedown = 3,    //!< Locked to portrait, upside down.
        Portrait_sensor     = 4,    //!< Both portrait orientations, sensor driven (but many devices won't do upside-down).

        Landscape_left      = 5,    //!< Locked to landscape left.
        Landscape_right     = 6,    //!< Locked to landscape right.
        Landscape_sensor    = 7,    //!< Both landscape orientations, sensor driven.
    };
    Q_ENUM(ScreenLockOrientation)

    /*!
     * \brief Get orientation lock (if set).
     * \note Read the screen lock, NOT the screen orientation.
     * \return See MobileUI::ScreenLockOrientation enum.
     */
    MobileUI::ScreenLockOrientation getScreenLockOrientation() const { return m_screenOrientation; }

    /*!
     * \brief Lock (or unlock) the screen orientation.
     * \param orientation: see MobileUI::ScreenLockOrientation enum.
     * \note - On iOS, Face ID iPhones never rotate upside-down, so Portrait_sensor behaves like Portrait there.
     *       - On iOS, the orientations must also be allowed by the application Info.plist.
     *       - On iPads with multitasking enabled the lock is ignored, unless UIRequiresFullScreen is set.
     *       - On Android 16+, apps targeting API level 36 have the lock ignored on large screens
     *         (smallest width of 600dp or more, like tablets and unfolded foldables).
     *
     * You can also achieve similar functionality through application manifest or plist:
     * - https://developer.android.com/guide/topics/manifest/activity-element.html#screen
     * - https://developer.apple.com/documentation/bundleresources/information_property_list/uisupportedinterfaceorientations
     */
    Q_INVOKABLE void setScreenLockOrientation(const MobileUI::ScreenLockOrientation orientation);

    /*!
     * \brief Get screen brightness set for the current app (on Android) or system wide (on iOS).
     * \return screen brightness, from 0 to 100, or -1 when unavailable.
     *
     * Returns the last value passed to setScreenBrightness() (not read back from the OS),
     * or if brightness has not been set by the app, the OS wide brightness level.
     * The OS wide level is read asynchronously, at startup and when the application becomes active again,
     * so it is -1 until the first read completes.
     */
    int getScreenBrightness() const { return (m_screenBrightness >= 0) ? m_screenBrightness : m_screenBrightnessSystem; }

    /*!
     * \brief Set screen brightness for the current app (on Android) or system wide (on iOS).
     * \param value: screen brightness, from 0 to 100 (values above 100 are clamped).
     *
     * Pass a negative value to release the override:
     * - On Android the app hands brightness control back to the system.
     * - On iOS the brightness is system wide, so the system brightness saved before
     *   the first change is restored. It is also restored while the app is not active,
     *   and the app brightness is re-applied once the app is active again.
     */
    Q_INVOKABLE void setScreenBrightness(const int value);

    /*!
     * \brief Get screensaver lock (if set).
     * \return on or off.
     */
    bool getScreenAlwaysOn() const { return m_screenAlwaysOn; }

    /*!
     * \brief Lock screensaver.
     * \param value: on or off.
     */
    Q_INVOKABLE void setScreenAlwaysOn(const bool value);

    /*!
     * \brief Tell whether the secure screen flag is set.
     * \return true if the window is marked secure.
     */
    bool getScreenSecure() const { return m_screenSecure; }

    /*!
     * \brief Mark the window as secure, to exclude its content from screen captures.
     * \param value: true to enable the secure flag, false to disable it.
     * \note Android only.
     *
     * On Android this sets the window FLAG_SECURE: the content is blocked from
     * screenshots and screen recordings, hidden from the recent-apps thumbnail, and
     * not shown on non-secure external displays.
     *
     * On iOS this is a no-op: there is no equivalent window flag (an app can only blur
     * its content when entering the background to hide it from the app switcher).
     */
    Q_INVOKABLE void setScreenSecure(const bool value);

    /*!
     * \brief Tell whether a high screen refresh rate has been requested.
     * \return true if the high refresh rate request is active.
     */
    bool getScreenHighRefreshRate() const { return m_screenHighRefreshRate; }

    /*!
     * \brief Request (or release) the highest screen refresh rate available.
     * \param value: true to request the highest refresh rate, false to hand control back to the system.
     * \note Android only.
     *
     * On Android this asks the window for the display mode with the highest refresh
     * rate at the current resolution (90/120 Hz on devices that support it).
     *
     * On iOS you cant opt into ProMotion (120 Hz) at run time, you need an Info.plist key instead:
     * "CADisableMinimumFrameDurationOnPhone" key (set to true)
     */
    Q_INVOKABLE void setScreenHighRefreshRate(const bool value);

    // Haptic feedbacks ////////////////////////////////////////////////////////

    /*!
     * \brief Haptic feedback styles that can be triggered through hapticFeedback().
     *
     * These mirror the iOS feedback generators (impact / notification / selection).
     * Android has no equivalent vocabulary, so each style is mapped to the closest
     * system haptic feedback constant (Android 11+), or to the closest predefined
     * VibrationEffect (or a short one-shot vibration) on older devices.
     */
    enum HapticFeedback {
        HapticSelection = 0,    //!< A light tick, for a selection moving between values.
        HapticLight,            //!< A light impact (small UI element).
        HapticMedium,           //!< A medium impact.
        HapticHeavy,            //!< A heavy impact (large UI element).
        HapticSuccess,          //!< A "task succeeded" notification feedback.
        HapticWarning,          //!< A "warning" notification feedback.
        HapticError,            //!< An "error / task failed" notification feedback.
    };
    Q_ENUM(HapticFeedback)

    /*!
     * \brief Trigger an haptic feedback.
     * \param type: see MobileUI::HapticFeedback enum. Default is a "light" haptic feedback.
     * \note iPads don't support haptic feedbacks.
     * \note On Android 11+ the system haptic feedback is used, honoring the user "touch feedback" setting.
     * \note On Android 10 and older the "android.permission.VIBRATE" must be added to the manifest.
     */
    Q_INVOKABLE void hapticFeedback(const MobileUI::HapticFeedback type = MobileUI::HapticLight);

    //! Alias of hapticFeedback().
    Q_INVOKABLE void vibrate(const MobileUI::HapticFeedback type = MobileUI::HapticLight);

    // Flash LED ///////////////////////////////////////////////////////////////

    /*!
     * \brief Tell whether the torch (rear camera flash LED) is currently on.
     * \return true if the torch is on.
     *
     * This reflects the last state MobileUI successfully applied,
     * false on devices with no flash.
     *
     * The state is read back when the application becomes active again, to catch changes made
     * outside of the application (on iOS only: Android only reports the torch state through
     * CameraManager.registerTorchCallback(), which requires a Java callback class MobileUI doesn't ship).
     */
    bool getTorchEnabled() const { return m_torchEnabled; }

    /*!
     * \brief Turn the torch (rear camera flash LED) on or off.
     * \param on: true to switch the torch on, false to switch it off.
     */
    Q_INVOKABLE void setTorchEnabled(const bool on);

    // Keyboard ////////////////////////////////////////////////////////////////

    /*!
     * \brief Get the height of the on-screen (virtual) keyboard.
     * \return the keyboard height in device-independent pixels, or 0 when the keyboard is hidden.
     *
     * Useful to reserve room / scroll content into view while typing.
     * The value tracks the keyboard as it is shown, hidden or resized.
     * The value doesn't update per frame while opening / closing animations are running.
     */
    int getKeyboardHeight() const { return m_keyboardHeight; }

    /*!
     * \brief Go back to Android home screen.
     *
     * You can use this method to bypass the default behavior for the Android back button,
     * which is to kill the application instead of doing what every single Android application does,
     * going back to the home screen...
     */
    Q_INVOKABLE void backToHomeScreen();

    // Color helpers ///////////////////////////////////////////////////////////

    /*!
     * \brief Compute the perceived luminance of a color.
     * \param color: the color to evaluate.
     * \return the perceived luminance (Rec. 601), normalized to the [0.0 ; 1.0] range.
     */
    Q_INVOKABLE static double colorLuminance(const QColor &color);

    /*!
     * \brief Tell whether a color is perceived as "light" using the Android cutoff.
     * \param color: the color to evaluate.
     * \return true if the color is light enough to warrant dark foreground icons.
     *
     * Uses the luminance cutoff (0.8) that matches Android's own behavior;
     * this is the rule MobileUI uses internally to auto-derive a bar theme.
     */
    Q_INVOKABLE static bool isColorLight_android(const QColor &color);

    /*!
     * \brief Tell whether a color is perceived as "light" using the HyperOS cutoff.
     * \param color: the color to evaluate.
     * \return true if the color is above the ~0.5 luminance cutoff.
     *
     * Xiaomi MIUI / HyperOS devices auto-contrast the status bar icons from the
     * bar background's perceived brightness, around a ~0.5 luminance cutoff.
     * Use this to predict which foreground those ROMs will pick.
     */
    Q_INVOKABLE static bool isColorLight_hyperos(const QColor &color);

private:
    // Device types
    bool m_isPhone = false;
    bool m_isTablet = false;

    // OS theme
    MobileUI::Theme m_osTheme = MobileUI::Auto;

    // System bars capabilities
    bool m_systemBarColorsSupported = false;

    /*!
     * \brief State of a system bar (status bar or navigation bar).
     *
     * When theme is not Auto, themeSet always equals theme.
     */
    struct SystemBar
    {
        QColor color;                               //!< Background color, applied to the bar
        QColor contentColor;                        //!< Used to derive a theme only, not applied to the bar
        MobileUI::Theme theme = MobileUI::Auto;     //!< Theme set manually
        MobileUI::Theme themeSet = MobileUI::Auto;  //!< Theme set manually or derived automatically
    };

    // System bars states
    SystemBar m_statusbar;
    SystemBar m_navbar;

    // System bar sizes and screen safe areas
    MobileUI::SafeAreaMetrics m_safeAreas;

    // Screen states
    MobileUI::ScreenLockOrientation m_screenOrientation = MobileUI::Unlocked;
    int m_screenBrightness = -1;        //!< Brightness set by the application, or -1 when unset.
    int m_screenBrightnessSystem = -1;  //!< OS wide brightness last read from the backend, or -1.
    bool m_screenAlwaysOn = false;
    bool m_screenSecure = false;
    bool m_screenHighRefreshRate = false;

    // Torch state
    bool m_torchEnabled = false;

    // On-screen keyboard height
    int m_keyboardHeight = 0;

    //! Connect to screen orientation, window and application state changes.
    void connectSignals();

    //! Request the (actual) device theme from the backend, delivered asynchronously to applyDeviceTheme().
    void refreshDeviceTheme();

    /*!
     * \brief Store the device theme read by the backend, and notify on change.
     * \param theme: MobileUI::Light or MobileUI::Dark.
     *
     * The Auto bar themes may fall back on the device theme, so they are re-derived on change.
     */
    void applyDeviceTheme(MobileUI::Theme theme);

    //! Request the OS wide screen brightness from the backend, delivered asynchronously to applyScreenBrightness().
    void refreshScreenBrightness();

    /*!
     * \brief Store the OS wide screen brightness read by the backend, and notify on change.
     * \param value: the OS wide screen brightness, from 0 to 100.
     */
    void applyScreenBrightness(int value);

    /*!
     * \brief Re-apply the status bar and navigation bar colors and themes.
     *
     * The native system bar colors and themes may be resetted by the OS (for instance
     * when the application returns to the foreground, or on rotation, ...), so this
     * pushes the cached colors/themes back to the platform.
     */
    void refreshSystemBars();

    /*!
     * \brief Recompute system bar sizes and screen safe areas.
     *
     * The values may be updated asynchronously (Android), through applySafeAreas().
     */
    void refreshSafeAreas();

    /*!
     * \brief Re-apply the screen orientation lock.
     *
     * An orientation lock set before the window is available would be ignored but recorded as set on iOS,
     * so re-apply it whenever the tracked application window changes (see refreshWindow()).
     */
    void refreshScreenOrientation();

    /*!
     * \brief Select the application window to track, and connect to its visibility, screen and safe area changes.
     * \return true if the tracked window changed.
     *
     * When the tracked window changes, the screen orientation lock is re-applied.
     *
     * Prefers the focus window, then keeps the current one (there is no focus window while
     * the application is in the background), then falls back to the first visible top-level window.
     */
    bool refreshWindow();

    //! Connections to the tracked window signals.
    QList<QMetaObject::Connection> m_windowConnections;

    /*!
     * \brief Connect to the orientation changes of the screen the application window is on.
     * \param screen: the screen to track (may be nullptr).
     */
    void trackScreen(QScreen *screen);

    //! Connection to the tracked screen orientationChanged() signal.
    QMetaObject::Connection m_screenOrientationConnection;

    //! Read the torch state back from the backend (if it can), and notify on change.
    void refreshTorch();

    /*!
     * \brief Store the on-screen keyboard height, and notify on change.
     * \param height: the backend height, or -1 to fall back to Qt's input method.
     */
    void applyKeyboardHeight(int height);

    /*!
     * \brief Store the system bar sizes and safe areas read by the backend, and notify on change.
     * \param m: the metrics read by the backend.
     *
     * The system bars are ignored in full screen mode.
     */
    void applySafeAreas(const MobileUI::SafeAreaMetrics &m);

    /*!
     * \brief Store a system bar background color, apply it, and re-derive the bar theme.
     * \param bar: m_statusbar or m_navbar.
     * \param color: the new background color (invalid colors are ignored).
     */
    void setBarColor(SystemBar &bar, const QColor &color);

    /*!
     * \brief Store a system bar content (reference) color, and re-derive the bar theme.
     * \param bar: m_statusbar or m_navbar.
     * \param color: the new content color (an invalid color clears it).
     */
    void setBarContentColor(SystemBar &bar, const QColor &color);

    /*!
     * \brief Store a system bar theme, and apply it (or the theme derived from it, when Auto).
     * \param bar: m_statusbar or m_navbar.
     * \param theme: see MobileUI::Theme enum.
     */
    void setBarTheme(SystemBar &bar, const MobileUI::Theme theme);

    /*!
     * \brief In Auto mode, (re)derive the bar theme from its reference color.
     * \param bar: m_statusbar or m_navbar.
     * \return true if bar.themeSet changed (it is not applied to the platform, nor notified).
     *
     * Uses the content color first if usable (valid and opaque), then the bar color,
     * and if neither is usable, falls back to the device theme.
     */
    bool deriveBarTheme(SystemBar &bar) const;

    //! Apply the bar color to the platform backend, if set and supported.
    void applyBarColor(const SystemBar &bar);

    //! Apply the bar theme (set or derived) to the platform backend, if any.
    void applyBarTheme(const SystemBar &bar);

    //! Emit statusbarUpdated() or navbarUpdated(), depending on the bar.
    void notifyBar(const SystemBar &bar);

    /*!
     * \brief Restartable retry timers re-setting the system bars / re-reading safe areas as they settle.
     *
     * Several signals (orientation, visibility, app-active, color-scheme) usually fire
     * back-to-back during one rotation or resume.
     *
     * Restarting the same set of timers (rather than queuing a fresh batch on every call)
     * coalesces such a burst into a single settle cascade aligned to the latest change.
     */
    QTimer m_retryTimers[4];
    const int m_retryDelays[4] = {66, 256, 512, 1024};

    PlatformMobileUI *m_platform = nullptr;         //!< Per-platform backend

    // Singleton
    explicit MobileUI(QObject *parent = nullptr);
    ~MobileUI() override = default;
};

/* ************************************************************************** */
#endif // MOBILEUI_H
