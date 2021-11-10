QT += core

MOBILEUI_VERSION = 1.0

SOURCES += $${PWD}/MobileUI.cpp
HEADERS += $${PWD}/MobileUI.h
INCLUDEPATH += $${PWD}

android {
    versionAtLeast(QT_VERSION, 6.0) {
        SOURCES += $${PWD}/MobileUI_android_qt6.cpp
    } else {
        QT += androidextras
        SOURCES += $${PWD}/MobileUI_android_qt5.cpp
    }
} else: ios {
    QT += gui-private
    LIBS += -framework UIKit
    OBJECTIVE_SOURCES += $${PWD}/MobileUI_ios.mm
} else {
    SOURCES += $${PWD}/MobileUI_dummy.cpp
}
