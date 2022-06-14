# MobileUI

MobileUI allows mobile QML applications to interacts with Android and iOS `status bar` and Android `navigation bar`.

MobileUI module is based on qtstatusbar by jpnurmi, with several improvements and additions.

> https://github.com/jpnurmi/qtstatusbar  

## Quick Documentation

### Build

Copy the MobileUI directory into your project, then include the library files with
either the `MobileUI.pro` QMake project file or the `CMakeLists.txt` CMake project file.

```qmake
include(src/thirdparty/MobileUI/MobileUI.pri)
```

```cmake
add_subdirectory(src/thirdparty/MobileUI)
target_link_libraries(${PROJECT_NAME} MobileUI::MobileUI)
```

### Register

Register the MobileUI QML module in your C++ main.cpp file:

```cpp
#include <MobileUI>

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);

    MobileUI::registerQML();

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
```

### Usage

Example usage in QML:

```
import MobileUI 1.0

MobileUI {
    statusbarTheme: MobileUI.Dark
    statusbarColor: "white"
    navbarColor: "white"
}
```

There is no navigation bar on iOS obviously, so it won't have any effects there.

## License

This project is licensed under the MIT license, see LICENSE file for details.
