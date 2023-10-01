# MobileUI

MobileUI allows QML applications to interact with Mobile specific features, like Android and iOS `status bar` and Android `navigation bar`.

You can see it in action in the [MobileUI demo](https://github.com/emericg/MobileUI_demo).

> Supports Qt6 and Qt5. QMake and CMake.

> Supports iOS 11+ (tested up to iOS 17 devices).

> Supports Android API 21+ (tested up to API 33 devices).

## Features

- Set Android `status bar` and `navigation bar` color and theme
- Set iOS `status bar` theme (iOS has no notion of status bar color, and has no navigation bar)
- Get device theme (light or dark mode)
- Get device `safe areas` (WIP)
- Lock screensaver
- Force screen orientation
- Trigger haptic feedback (vibration)

## Screenshots

![MobileUIs](https://raw.githubusercontent.com/emericg/screenshots_flathub/master/MobileUI/MobileUI.png)

## Quick start

### Build

To get started, simply checkout the MobileUI repository as a submodule, or copy the
MobileUI directory into your project, then include the library files with either
the `MobileUI.pro` QMake project file or the `CMakeLists.txt` CMake project file.

```qmake
include(MobileUI/MobileUI.pri)
```

```cmake
add_subdirectory(MobileUI/)
target_link_libraries(${PROJECT_NAME} MobileUI::MobileUI)
```

### Use

First, you need to register the MobileUI QML module in your C++ main.cpp file.  
You can also use MobileUI directly in the C++ code if you want to.  

```cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <MobileUI>

int main() {
    QGuiApplication app();

    MobileUI::registerQML(); // that is required

    MobileUI::setStatusbarColor("white"); // use it directly if you want

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
```

Example usage in QML:

```qml
import QtQuick
import MobileUI

ApplicationWindow {
    MobileUI {
        id: mobileUI

        statusbarColor: "white"
        statusbarTheme: MobileUI.Light
        navbarColor: "white"
        navbarTheme: MobileUI.Light
    }
}
```

## Quick documentation

### Window modes

Now there are three modes you can use on Android and iOS applications:

#### "Regular"

> ApplicationWindow visibility: Window.AutomaticVisibility

> ApplicationWindow flags: Qt.Window

- Black status bar on iOS (you can't change that).
- User can set colors for both status and navigation bars on Android.
- Available geometry is fullscreen - system bars height.

That is the default mode on Android, but the infamous "white bar" bug make it pretty much useless.

#### "Regular with transparent bars"

> ApplicationWindow visibility: Window.AutomaticVisibility

> ApplicationWindow flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint

- The status bar is transparent on iOS, and you can choose the theme. Your application can draw a bar "manually" to visualize it.
- The status bar is transparent on Android, and you can choose the theme. Your application can draw a bar "manually" to visualize it, or force a system bar color (it will be drawn above everyting).
- The navigation bar is transparent on Android, and you can choose the theme. MobileUI will prevent you from forcing a color, because that would change the windows mode back to "regular", but not really.
- Available geometry is the full screen; including what's behind system bars.

That is the default mode on iOS.

#### Full screen / "immersive" modes

> ApplicationWindow visibility: Window.FullScreen

- No system bars drawn at all.
- Available geometry is the full screen.

### Settings colors and theme

> statusbarColor

Set the status bar color (if available).  
This is a QColor, so you can use an hexadecimal value ("#fff") or even a named color ("red"). And you can use "transparent" too.  
Settings a color will also set a theme, by automatically evaluating if the bar color is more light or dark. You can force a theme if you are not satisfied by the result.  

> statusbarTheme

Set the status bar theme explicitly, MobileUI.Light or MobileUI.Dark.

On iOS and Android API 28+, the theme must be set each time the window visibility or orientation changes. This is done automatically.

> navbarColor

Set the navigation bar color (if available).  
This is a QColor, so you can use an hexadecimal value ("#fff") or even a named color ("red"). And you can use "transparent" too.  
Settings a color will also set a theme, by automatically evaluating if the bar color is more light or dark. You can force a theme if you are not satisfied by the result.  

> navbarTheme

Set the navigation bar theme explicitly, MobileUI.Light or MobileUI.Dark.

On Android API 28+, the theme must be set each time the window visibility or orientation changes. This is done automatically.

### Device theme

> deviceTheme

You can get the device OS theme by reading the deviceTheme property.  
MobileUI doesn't listen to the change affecting this value and won't signal you when it's changed. 

You should probably not switch your app theme while it's being used anyway, so it may be wise to only check this value when the application is loading or brought back to the foreground.  

```qml
Connections {
    target: Qt.application
    function onStateChanged() {
        case Qt.ApplicationActive:
            console.log("device theme (%1)".arg(mobileUI.deviceTheme ? "dark" : "light"))
            break
    }
}
```

### Safe areas

> statusbarHeight

> navbarHeight


> safeAreaTop

> safeAreaLeft

> safeAreaRight

> safeAreaBottom

### Lock screensaver

Either call ```setScreenAlwaysOn(true/false)``` or set ```screenAlwaysOn: true/false``` in QML.

This will disable/enable the device screensaver.

```qml
mobileUI.setScreenAlwaysOn(true)
mobileUI.screenAlwaysOn: true
```

### Force screen orientation

This will force the device screen orientation into one of the available values. This canot be used to read the actual device orientation.

Either call ```setScreenOrientation(MobileUI.ScreenOrientation)``` or set ```screenOrientation: MobileUI.ScreenOrientation``` in QML.

```qml
mobileUI.setScreenOrientation(MobileUI.Landscape_left)
mobileUI.screenOrientation: MobileUI.Landscape_right
```

Available orientations:

- Unlocked
- Portrait
- Portrait_upsidedown
- Portrait_sensor // only available on Android
- Landscape_left
- Landscape_right
- Landscape_sensor // only available on Android

### Haptic feedback

Produce a simple haptic feedback, called "notification feedback" on iOS or a "tick" on Android.

```qml
mobileUI.vibrate()
```

## Licensing

This project is licensed under the [MIT license](LICENSE).

This project is based on [qtstatusbar](https://github.com/jpnurmi/qtstatusbar) by jpnurmi.
