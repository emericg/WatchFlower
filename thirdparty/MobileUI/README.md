# MobileUI

MobileUI allows QML applications to interact with Mobile specific features, like Android and iOS `status bar` and Android `navigation bar`.

You can see it in action in the [MobileUI demo](https://github.com/emericg/MobileUI_demo).

> Supports Qt 6.8+ with CMake.

> Supports iOS 16+. Tested up to iOS 17.7 devices.

> Supports Android 9+ (API 28). Tested up to Android 16 (API 36) devices.

> [!IMPORTANT]
> If you want the modern architecture but without the QML singleton for MobileUI, you can still use the **LEGACY** 'v1' branch.  
> It could help you migrate your application from an older MobileUI version. Same requirements (Qt 6.8+ and CMake).  

> [!IMPORTANT]
> If you need a QMake build system, or support for Qt5 / earlier Qt6 version, you can still use the **LEGACY** 'v0' branch.  


## Features

- Set Android `status bar` and `navigation bar` colors and theme
- Set iOS `status bar` theme (iOS has no notion of status bar color, and has no navigation bar)
- Get device theme (light or dark mode)
- Get device `safe areas`
- Lock screensaver
- Set screen orientation
- Set screen brightness
- Trigger haptic feedback (vibration)
- Android back button helper

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

MobileUI is a QML singleton, so it is registered automatically by the QML engine.

```qml
import QtQuick
import MobileUI

// Do not use ApplicationWindow, or you'll get Qt inferior safe area implementation!
Window {

    // EITHER set the variables declaratively
    Component.onCompleted: {
        MobileUI.statusbarColor = "red"
        MobileUI.statusbarTheme = MobileUI.Dark
    
        MobileUI.navbarColor = "blue"
        MobileUI.navbarTheme = MobileUI.Dark
    }
    
    // OR use bindings
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


## Quick documentation

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
- The navigation bar is transparent on Android, and you can choose the theme. MobileUI will prevent you from forcing a color, because that would change the windows mode back to "regular", but not really.
- Available geometry is the full screen, including what's behind system bars.

That is the default mode on iOS. This is the mandatory default on Android 15+ (API 35+).

See Android best practices: https://developer.android.com/design/ui/mobile/guides/foundations/system-bars

> [!TIP]
> That is the mode we really recommand! It offers the most flexibility, but you'll need to handle the space occupied by the status and navigation bars yourself.

#### Full screen / "immersive" mode

```qml
Window {
    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    visibility: Window.FullScreen
}
```

- No system bars drawn at all.
- Available geometry is the full screen.

### Settings colors and theme

> statusbarColor

Set the status bar color (if available).

This is a QColor, so you can use a hexadecimal value "`#fff"` or even a named color `"red"`. And you can use `"transparent"` too.

Settings a color will also set a theme, by automatically evaluating if the bar color is more light or dark. You can force a theme if you are not satisfied by the result.

> statusbarTheme

Set the status bar theme explicitly, `MobileUI.Light` or `MobileUI.Dark`.

On iOS and Android API 28+, the theme must be set each time the window visibility or orientation changes. This is handled automatically by MobileUI.

> [!WARNING]
> When using a Xiaomi MIUI / HyperOS devices in dark mode, you cannot control the status bar theme!  
> These ROMs use a form of auto-contrast the status bar icons from the perceived brightness of the bar's background color.  
> You can use the isColorLight_hyperos() helper to check if the color you choose is below of above the ~0.5 luminance point cutoff used.  

> navbarColor

Set the navigation bar color (if available).

This is a QColor, so you can use a hexadecimal value "`#fff"` or even a named color `"red"`. And you can use `"transparent"` too.

Settings a color will also set a theme, by automatically evaluating if the bar color is more light or dark. You can force a theme if you are not satisfied by the result.

> navbarTheme

Set the navigation bar theme explicitly, `MobileUI.Light` or `MobileUI.Dark`.

On Android API 28+, the theme must be set each time the window visibility or orientation changes. This is handled automatically by MobileUI.

### Device theme

> deviceTheme

You can get the device OS theme by reading the deviceTheme property.

MobileUI doesn't listen to the change affecting this value and won't signal you when it's changed.

You should probably not switch your app theme while it's being used anyway,
so it may be wise to only check this value when the application is loading or brought back to the foreground.

```qml
Connections {
    target: Qt.application
    function onStateChanged() {
        case Qt.ApplicationActive:
            console.log("device theme (%1)".arg(MobileUI.deviceTheme ? "dark" : "light"))
            break
    }
}
```

### Safe areas

Safe areas handling is not straightforward, unfortunately. Most of it will be left into your care.

> statusbarHeight

Status bar size, in pixels.

Status bar is always at the top of the screen, when visible. Otherwise this value will be set to 0.

> navbarHeight

Navigation bar size, in pixels.

Navigation bar is usually at the bottom of the screen, when visible. Otherwise this value will be set to 0.

The navigation bar can be left/right of the screen, when the phone is rotated. Then this value will be set to 0, and the left/right safe areas will integrate the navbar size.

> safeAreaTop

> safeAreaLeft

> safeAreaRight

> safeAreaBottom

These values are changed automatically when the screen is rotated.

safeAreaTop and safeAreaBottom will integrate the system bar height if needed.


### Lock screensaver

Either call `setScreenAlwaysOn(true/false)` or set `screenAlwaysOn: true/false` (in QML) to disable/re-enable the device screensaver.

```qml
MobileUI.setScreenAlwaysOn(true)
MobileUI.screenAlwaysOn: true
```

### Set screen orientation

This will force the device screen orientation into one of the available values.
This cannot be used to read the actual device orientation.

Either call `setScreenOrientation(MobileUI.ScreenOrientation)` or set `screenOrientation: MobileUI.ScreenOrientation` (in QML).

```qml
MobileUI.setScreenOrientation(MobileUI.Landscape_left)
MobileUI.screenOrientation: MobileUI.Landscape_right
```

Available orientations:

> Unlocked

> Portrait

> Portrait_upsidedown // only available on Android?

> Portrait_sensor // only available on Android

> Landscape_left

> Landscape_right

> Landscape_sensor // only available on Android

### Set screen brightness

Set screen brightness for the currently running application (on Android) or system wide (on iOS).

```qml
Slider {
    from: 0
    to: 100
    value: MobileUI.screenBrightness
    onMoved: MobileUI.screenBrightness = value
}
```

### Haptic feedback

Produce a simple haptic feedback, called "notification feedback" on iOS or a "tick" on Android.

No model of iPad includes a haptic engine. Android tablets usually have one.

```qml
MobileUI.vibrate()
```

### Back to home screen

#### Android

You can use this method to bypass the default behavior for the Android back button,
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

### iOS

- It looks like forcing the screen orientation on an iPad is not allowed.

### Android

- Transition between the splash screen and the application window will glitch. As far as I know there is no way to fix that.  
You'll see the window beeing resized (more or less the size of the status bar), and the status bar changing color, usually to black, but you might be lucky and
get a light grey depending on your device. It's bad if you're coming from a white splash screen, seeing a black bar appear, and going to a white application background...

- Qt 6.11 force your app to go fullscreen each time it goes back to the foreground...

- All in all, window modes, geometry, rotation and many smaller things are just buggy on Qt for Android, and often subtly broken depending on which Qt version is used. Using only Qt 6.8 and up helps a lot...

## Licensing

This project is licensed under the [MIT license](LICENSE).

This project is based on [qtstatusbar](https://github.com/jpnurmi/qtstatusbar) by jpnurmi.
