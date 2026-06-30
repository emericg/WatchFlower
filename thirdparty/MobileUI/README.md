# MobileUI

MobileUI allows QML applications to interact with mobile specific features, like Android and iOS `status bar` and Android `navigation bar`.

You can see it in action in the [MobileUI demo](https://github.com/emericg/MobileUI_demo).

> Supports Qt 6.8+ with CMake.

> Supports iOS 16+. Tested up to iOS 17.7 devices.

> Supports Android 9+ (API 28). Tested up to Android 16 (API 36) devices.

> [!IMPORTANT]
> If you want a more modern version than v0, but with the same API / usage, and a bit higher requirements (Qt 6.8+ and CMake), you can use the **LEGACY** 'v1' branch.  

> [!IMPORTANT]
> If you need a QMake build system, or support for Qt5 / earlier Qt6 version, you can use the **LEGACY** 'v0' branch.  


## Features

- Set Android `status bar` and `navigation bar` colors and theme
- Set iOS `status bar` theme (iOS has no notion of status bar color, and has no navigation bar)
- Get device theme (light or dark mode)
- Get device system bars and keyboard heights
- Get device `safe areas`
- Set screen brightness
- Lock screen orientation
- Lock screensaver
- Toggle camera flash
- Trigger haptic feedbacks (vibrations)
- Android high screen refresh rate toggle
- Android "secure screen" helper
- Android "back button" helper
- iOS application icon badge number


## Screenshots

![MobileUIs](https://raw.githubusercontent.com/emericg/screenshots_flathub/master/MobileUI/MobileUI.png)


## Quick start

### Build

To get started, simply checkout the MobileUI repository as a submodule, or copy the
MobileUI directory into your project, then include the `CMakeLists.txt` CMake project file:

```cmake
add_subdirectory(MobileUI/)
target_link_libraries(${PROJECT_NAME} PRIVATE MobileUI MobileUI_plugin)
```

You might need some hacks so the QML Language Server recognize the MobileUI module:

```cmake
set(QML_IMPORT_PATH "${CMAKE_BINARY_DIR}/MobileUI/" CACHE STRING "QML Modules import paths" FORCE)
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
```

### Use

MobileUI is a proper CMake QML module (and a QML singleton), so it is registered automatically by the QML engine.

```qml
import QtQuick
import MobileUI

// Use a regular Window and not an ApplicationWindow, or you'll get Qt's inferior safe area implementation!
Window {

    // EITHER set the variables declaratively
    Component.onCompleted: {
        MobileUI.statusbarColor = "grey"
        MobileUI.statusbarTheme = MobileUI.Dark
    
        MobileUI.navbarColor = "blue"
        MobileUI.navbarTheme = MobileUI.Light
    }

    // OR use bindings (for more dynamic use cases)
    Binding {
        target: MobileUI
        property: "statusbarTheme"
        value: { return YourTheme.themeStatusbar }
    }
    Binding {
        target: MobileUI
        property: "navbarColor"
        value: {
            if (something) return YourTheme.colorForeground
            return YourTheme.colorBackground
        }
    }

    // OR use our QML dispatcher (for more dynamic use cases, to bind values more easily)
    MobileUI_dispatcher {
        statusbarColor: "white"
        statusbarTheme: MobileUI.Auto

        navbarColor: {
            // you don't need these pesky `Binding` blocks anymore!
            if (something) return YourTheme.colorForeground
            return YourTheme.colorBackground
        }
        navbarTheme: MobileUI.Auto

        // Also covers the screen and device settings!
        screenAlwaysOn: true
        screenLockedOrientation: MobileUI.Portrait
        screenBrightness: 80
        screenSecure: false
        screenHighRefreshRate: true
        torchEnabled: false
        iconBadgeNumber: 0

        // Read-only values (safe areas, device theme, bar heights) stay on the MobileUI singleton

        // Declare a single instance. Or else :/
    }

    // Use SafeAreas however you see fit
    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: MobileUI.safeAreaLeft
        anchors.right: parent.right
        anchors.rightMargin: MobileUI.safeAreaRight

        height: 333
        color: "purple"
    }
}
```

You can also use MobileUI directly from C++ code if you want.

```cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <MobileUI>

int main() {
    QGuiApplication app();

    MobileUI::getInstance()->setStatusbarColor("white");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
```


## Documentation

### Window modes

There are three modes you can use on Android and iOS applications:

#### "Regular"

```qml
Window {
    flags: Qt.Window
    visibility: Window.AutomaticVisibility
}
```

- Black status bar on iOS (you can't change that).
- User can set colors for both status and navigation bars on Android.
- Available geometry is fullscreen - system bars height.
- No (real) need to handle safe areas.

That is was default mode on Android, but it has been deprecated on Android 15 (API 35). You should NOT use this mode.

#### "Regular with transparent bars" / "edge to edge" mode

```qml
Window {
    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    visibility: Window.AutomaticVisibility
}
```

- The status bar is transparent on iOS, and you can choose the theme. Your application can draw a bar "manually" to visualize it.
- The status bar is transparent on Android, and you can choose the theme. Your application can draw a bar "manually" to visualize it, or force a system bar color (it will be drawn above everyting).
- The navigation bar is transparent on Android, and you can choose the theme. On Android 15+ (API 35+) forcing a navigation bar color has no effect (the call is a no-op), as that would conflict with the mandatory edge-to-edge mode. On older API levels the color is still applied through a translucent flag.
- Available geometry is the full screen, including what's behind system bars.

That is the default mode on iOS. This is the mandatory default on Android 15+ (API 35+).

See Android best practices: https://developer.android.com/design/ui/mobile/guides/foundations/system-bars

> [!TIP]
> The "edge to edge" mode is the one we really recommand! It offers the most flexibility, matches modern standards, but you'll need to handle the space occupied by the status and navigation bars yourself.

#### Full screen / "immersive" mode

```qml
Window {
    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    visibility: Window.FullScreen
}
```

- No system bars drawn at all.
- Available geometry is the full screen.

### Setting colors and theme

> statusbarColor

Set the status bar color (if available).

This is a QColor, so you can use a hexadecimal value `"#fff"` or even a named color `"red"`. And you can use `"transparent"` too.

By default the theme is `Auto`, so setting a color also updates the derived theme (evaluated from whether the bar color is perceived as light or dark). Set an explicit theme to override that behavior.

> [!IMPORTANT]
> The status bar color is only honored up to **Android 14 (API 34)**. On **Android 15+ (API 35+)** the platform `setStatusBarColor()` is deprecated and turned into a no-op: edge-to-edge is mandatory, the bar stays transparent, and setting `statusbarColor` has no effect. Paint your own background / content behind the (now transparent) bar instead — see the "edge to edge" window mode. The icon contrast (`statusbarTheme`) keeps working on every supported version.

> statusbarContentColor

The "reference color" used to derive the theme while `statusbarTheme` is `Auto` and the statusbarColor is `"transparent"` (or not drawn).

This is meant to be used in edge-to-edge mode: you can choose to use a fully transparent status bar, and paint your own content freely behind that bar, but you want the text/icon contrast to still follow that content color.

When unset, derivation falls back to `statusbarColor`, and if that isn't set either, the OS will take back control of the theme.

> statusbarTheme

Set the status bar theme: `MobileUI.Auto` (the default), `MobileUI.Light` or `MobileUI.Dark`.

This drives the status bar foreground contrast — the clock, status icons and text. `Light` means a light bar background, so the system draws dark icons; `Dark` means a dark background, so it draws light icons.

`Auto` derives the theme from the bar's reference color — `statusbarContentColor` if used, otherwise the default `statusbarColor` — and leaves the theme to the OS when no usable color is available. `Light` / `Dark` force it explicitly.

Unlike `statusbarColor` (Android only, and capped at API 34), the theme keeps working everywhere — on iOS, and on Android including **Android 15+ (API 35+)** in edge-to-edge mode. On Android it goes through `WindowInsetsController.setSystemBarsAppearance()` on API 30+, and the legacy `SYSTEM_UI_FLAG_LIGHT_STATUS_BAR` system-UI flag on API 28–29.

On iOS and Android API 28+, the theme must be set each time the window visibility or orientation changes. This is handled automatically by MobileUI.

> [!WARNING]
> When using a Xiaomi MIUI / HyperOS devices in dark mode, you cannot control the status bar theme!  
> These ROMs use a form of auto-contrast the status bar icons from the perceived brightness of the bar's background color.  
> You can use the isColorLight_hyperos() helper to check if the color you choose is below of above the ~0.5 luminance point cutoff used.  

> statusbarThemeSet

Read-only: the theme actually applied right now (`MobileUI.Light` or `MobileUI.Dark`). In `Auto` mode with no usable bar color, it falls back to the device OS theme as a deterministic default.

> navbarColor

Set the navigation bar color (if available).

This is a QColor, so you can use a hexadecimal value `"#fff"` or even a named color `"red"`. And you can use `"transparent"` too.

The color is barely visible under **gesture navigation**: the system keeps the gesture pill area transparent regardless of the requested color, so `navbarColor` mostly matters for the classic **3-button / 2-button navigation**.

By default the theme is `Auto`, so setting a color also updates the derived theme. Set an explicit theme to override that behavior.

> [!IMPORTANT]
> The navigation bar color is only honored up to **Android 14 (API 34)**. On **Android 15+ (API 35+)** the platform `setNavigationBarColor()` is deprecated and turned into a no-op: edge-to-edge is mandatory, the bar stays transparent, and setting `navbarColor` has no effect. Paint your own background / content behind the (transparent) bar instead — see the "edge to edge" window mode. The icon contrast (`navbarTheme`) keeps working on every supported version.

> navbarContentColor

The "reference color" used to derive the theme while `navbarTheme` is `Auto`.

This is meant to be used in edge-to-edge mode: you can choose to use a fully transparent navigation bar, and paint your own content freely behind that bar, but you want the text/icon contrast to still follow that content color.

When unset, derivation falls back to `navbarColor`, and if that isn't set either, the OS will take back control of the theme.

> navbarTheme

Set the navigation bar theme: `MobileUI.Auto` (the default), `MobileUI.Light` or `MobileUI.Dark`.

This drives the navigation bar foreground contrast — the 3-button icon color, or the gesture handle tint. `Light` means a light bar background, so the system draws dark icons; `Dark` means a dark background, so it draws light icons.

`Auto` derives the theme from the bar's reference color — `navbarContentColor` if used, otherwise the default `navbarColor` — and leaves the theme to the OS when no usable color is available. `Light` / `Dark` force it explicitly.

Unlike `navbarColor`, the theme keeps working on every supported Android version, including **Android 15+ (API 35+)** in edge-to-edge mode. It goes through `WindowInsetsController.setSystemBarsAppearance()` on API 30+, and the legacy `SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR` system-UI flag on API 28–29.

On Android API 28+, the theme must be set each time the window visibility or orientation changes. This is handled automatically by MobileUI.

> navbarThemeSet

Read-only: the theme actually applied right now (`MobileUI.Light` or `MobileUI.Dark`). In `Auto` mode with no usable bar color, it falls back to the device OS theme as a deterministic default.

### Device theme

> deviceTheme

You can get the device OS theme by reading the deviceTheme property.

MobileUI listen to the change affecting this value and will signal you when it's changed.

You should probably not switch your app theme while it's being used anyway,
so it may be wise to only check this value when the application is loading or brought back to the foreground.

```qml
Connections {
    target: Qt.application
    function onStateChanged() {
        if (Qt.application.state === Qt.ApplicationActive) {
            console.log("device theme (%1)".arg(MobileUI.deviceTheme ? "dark" : "light"))
        }
    }
}
```

### Safe areas

Safe areas handling is never straightforward, unfortunately. The module provides the values, but how you decide to use it is left in your care.  
MobileUI listen to the change affecting these values.  

> statusbarHeight

Status bar size, in pixels, DPI adjusted.

Status bar is always at the top of the screen, when visible. Otherwise this value will be set to 0.

> navbarHeight

Navigation bar size, in pixels, DPI adjusted.

Navigation bar is usually at the bottom of the screen, when visible. Otherwise this value will be set to 0.

The navigation bar can be left/right of the screen, when the phone is rotated. Then this value will be set to 0, and the left/right safe areas will integrate the navbar size.

> safeAreaTop

> safeAreaLeft

> safeAreaRight

> safeAreaBottom

These values are changed automatically when the screen is rotated.

safeAreaTop and safeAreaBottom will integrate the system bar height if needed.

### Keyboard height

> keyboardHeight

The height of the on-screen virtual keyboard, in pixels, DPI adjusted, or 0 when the keyboard is hidden.

Useful to reserve room or scroll content into view while the user is typing.

On Android the value is read natively, elsewhere it falls back to Qt's input method value. MobileUI updates this value as the keyboard is shown, hidden or resized. The value doesn't update per frame while opening / closing animations are running.

### Set screen brightness

Set screen brightness for the currently running application (on Android) or system wide (on iOS).

Brightness is expressed from 0 to 100. Reading it returns -1 when brightness is unavailable.

```qml
Slider {
    from: 0
    to: 100
    value: MobileUI.screenBrightness
    onMoved: MobileUI.screenBrightness = value
}
```

Set a negative value to release the override and hand brightness control back to the system. On Android this restores the OS-managed brightness; on iOS there is no per-app override so it does nothing.

```qml
MobileUI.screenBrightness = -1
```

### Lock screen orientation

This will force the device screen orientation into one of the available values.  
This cannot be used to read the actual device orientation.  

Either call `setScreenLockOrientation(MobileUI.ScreenLockOrientation)` or set `screenLockedOrientation: MobileUI.ScreenLockOrientation` (in QML).

```qml
MobileUI.setScreenLockOrientation(MobileUI.Landscape_left)
MobileUI.screenLockedOrientation = MobileUI.Landscape_right
```

Available orientations:

> Unlocked

> Portrait

> Portrait_upsidedown

> Portrait_sensor // on iOS, falls back to a fixed Portrait

> Landscape_left

> Landscape_right

> Landscape_sensor // on iOS, allows both landscape orientations

### Lock screensaver

Either call `setScreenAlwaysOn(true/false)` or set `screenAlwaysOn: true/false` (in QML) to disable/re-enable the device screensaver.

```qml
MobileUI.setScreenAlwaysOn(true)
MobileUI.screenAlwaysOn = true
```

### Secure screen

Mark the window as secure, to exclude its content from screen captures.

Either call `setScreenSecure(true/false)` or set `screenSecure: true/false` (in QML).

```qml
MobileUI.setScreenSecure(true)
MobileUI.screenSecure = true
```

On Android this sets the window `FLAG_SECURE`: the content is blocked from screenshots and screen recordings, hidden from the recent-apps thumbnail, and not mirrored to non-secure external displays.

> [!IMPORTANT]
> There is no `FLAG_SECURE` equivalent on iOS, a screenshot or a screen recording cannot be blocked.

### High refresh rate

Request the highest screen refresh rate available (e.g. 90/120 Hz on devices that support it).

Either call `setHighRefreshRate(true/false)` or set `screenHighRefreshRate: true/false` (in QML).

```qml
MobileUI.setHighRefreshRate(true)
MobileUI.screenHighRefreshRate = true
```

On Android this asks the window for the display mode with the highest refresh rate **at the current resolution** (it never switches resolution). Set it back to `false` to hand control back to the system.

Opting into ProMotion (120 Hz) on iOS is not a runtime call: it is a build-time decision.
You enable it with this key intto your application `Info.plist`:

```xml
<key>CADisableMinimumFrameDurationOnPhone</key>
<true/>
```

### Haptic feedback

Trigger a haptic feedback. Call `hapticFeedback()` or `vibrate()` for a default (light) feedback, or pass a `MobileUI.HapticFeedback` value to pick a more specific feedback.

```qml
MobileUI.hapticFeedback() // default light feedback
MobileUI.hapticFeedback(MobileUI.HapticHeavy)
```

Available feedbacks:

> HapticSelection // a light tick

> HapticLight // a light impact

> HapticMedium // a medium impact

> HapticHeavy // a heavy impact

> HapticSuccess // a "task succeeded" notification

> HapticWarning // a "warning" notification

> HapticError // an "error / task failed" notification

These map directly to the iOS feedback generators (selection / impact / notification). Android has no such vocabulary, so each style is mapped to the closest predefined `VibrationEffect` (or a short one-shot vibration on older devices).

No model of iPad includes a haptic engine. Android tablets usually have one.

> On Android, the `android.permission.VIBRATE` permission must be present in the manifest.

### Torch

Toggle the rear camera flash LED (torch / flashlight).

Either call `setTorchEnabled(true/false)` or set `torchEnabled: true/false` (in QML).

```qml
MobileUI.setTorchEnabled(true)
MobileUI.torchEnabled = true
```

`torchEnabled` reflects the state actually applied: on a device without a rear flash the request is silently ignored and the property stays `false`.

On Android no permission is required, the `CAMERA` permission is *not* needed to use `setTorchMode()`.
### Application icon badge

> [!NOTE]
> **iOS only.**

Set the number shown on the application icon badge.

```qml
MobileUI.iconBadgeNumber = 3 
MobileUI.iconBadgeNumber = 0 // clear the badge
```

> On iOS, the `badge notification` authorization must be granted by the user for the badges to show.

> Android has no standard launcher badge API (badges are tied to notifications and are launcher specific) so this will do nothing.

### Back to home screen

> [!NOTE]
> **Android only.**

You can use this method to bypass the default Qt behavior for the Android back button,
which is to kill the application instead of doing what every single Android application does,
going back to the home screen...

Either use it on your application window 'onClosing' signal:

```qml
onClosing: (close) => {
    if (Qt.platform.os == "android") {
        close.accepted = false
        MobileUI.backToHomeScreen()
    }
}
```

Or on an appropriate 'onBackPressed' signal:

```qml
Keys.onBackPressed: {
    MobileUI.backToHomeScreen()
}
```

#### iOS

Going back to the home screen from an application is not possible on iOS, and thus this function does nothing.


## Caveats

- When using Qt 6.9+, Qt has introduced its own "SafeArea" system. Because it's still fairly buggy, and not really powerful enough to match MobileUI features, I would advise not to use it just yet, and for that you'll need to use regular `Window` instead of `ApplicationWindow` QML item.

### Android

- Transition between the splash screen and the application window will glitch. As far as I know there is no way to fix that.  
You'll see the window beeing resized (more or less the size of the status bar), and the status bar changing color, usually to black, but you might be lucky and
get a light grey depending on your device. It's bad if you're coming from a white splash screen, seeing a black bar appear, and going to a white application background...

- Qt 6.11 force your app to go fullscreen each time it goes back to the foreground...

- All in all, window modes, geometry, rotation and many smaller things are just buggy on Qt for Android, and often subtly broken depending on which Qt version is used. Using only Qt 6.8 and up helps a lot...


## Licensing

This project is based on [qtstatusbar](https://github.com/jpnurmi/qtstatusbar) by jpnurmi.

This project is licensed under the [MIT license](LICENSE).

> Copyright (c) 2016 J-P Nurmi (jpnurmi)  

> Copyright (c) 2026 Emeric Grange (emeric.grange@gmail.com)  
