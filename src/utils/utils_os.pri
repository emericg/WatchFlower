
linux:!android {
    QT += dbus

    # Linux utils
    SOURCES += src/utils/utils_os_linux.cpp
    HEADERS += src/utils/utils_os_linux.h
}

macx {
    LIBS    += -framework IOKit

    # macOS utils
    SOURCES += src/utils/utils_os_macos.mm
    HEADERS += src/utils/utils_os_macos.h
}

win32 {
    # Windows utils
    SOURCES += src/utils/utils_os_windows.cpp
    HEADERS += src/utils/utils_os_windows.h
}

android {
    # Android utils
    versionAtLeast(QT_VERSION, 6.0) {
        QT += core-private

        SOURCES += src/utils/utils_os_android_qt6.cpp
        HEADERS += src/utils/utils_os_android.h
    } else {
        QT += androidextras

        SOURCES += src/utils/utils_os_android_qt5.cpp
        HEADERS += src/utils/utils_os_android.h
    }
}

ios {
    LIBS    += -framework UIKit

    # iOS utils
    SOURCES += src/utils/utils_os_ios.mm
    HEADERS += src/utils/utils_os_ios.h
}
