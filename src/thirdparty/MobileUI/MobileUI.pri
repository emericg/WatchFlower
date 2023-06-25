QT += core gui qml

SOURCES += $${PWD}/MobileUI.cpp

HEADERS += $${PWD}/MobileUI.h \
           $${PWD}/MobileUI_private.h

INCLUDEPATH += $${PWD}

android {
    versionAtLeast(QT_VERSION, 6.0) {
        SOURCES += $${PWD}/MobileUI_android_qt6.cpp
    } else {
        QT += androidextras
        SOURCES += $${PWD}/MobileUI_android_qt5.cpp
    }
} else: ios {
    LIBS += -framework UIKit
    OBJECTIVE_SOURCES += $${PWD}/MobileUI_ios.mm
} else {
    SOURCES += $${PWD}/MobileUI_dummy.cpp
}
