# SunAndMoon

SunAndMoon is a wrapper for QML applications providing information about sunrise/sunset, moonrise/moonset and moonphase, among more detailed infos. Works with Qt5 and Qt6.

SunAndMoon wrapper is based on `MoonPhase`, `MoonRise` and `SunRise` by Cyrus Rahman.

> https://github.com/signetica  

## Quick start

### Build

Copy the SunAndMoon directory into your project, then include the library files with
either the `SunAndMoon.pro` QMake project file or the `CMakeLists.txt` CMake project file.

```qmake
include(src/thirdparty/SunAndMoon/SunAndMoon.pri)
```

```cmake
add_subdirectory(src/thirdparty/SunAndMoon)
target_link_libraries(${PROJECT_NAME} SunAndMoon::SunAndMoon)
```

### Usage

First, you need to register the SunAndMoon QML module in your C++ main.cpp file.  
You can also use SunAndMoon directly in the code if you want to.  

```cpp
#include <SunAndMoon>

int main() {
    QGuiApplication app();

    SunAndMoon sam;
    engine_context->setContextProperty("sunAndMoon", &sam);

    sam.set(45, 6, QDateTime::currentDateTime());
    sam.print();

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
```

Example usage in QML:

```qml
ApplicationWindow {
    Component.onCompleted: {
        // Update sun position
        sunAndMoon.update()
        // Print
        console.log("sunrise time: " + sunAndMoon.sunrise + " / sunset time: " + sunAndMoon.sunset)
    }
}
```

## License

This project is licensed under the MIT license, see LICENSE file for details.
