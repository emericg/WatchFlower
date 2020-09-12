QT += core

MOBILEUI_VERSION = 1.0

SOURCES += $${PWD}/MobileUI.cpp
HEADERS += $${PWD}/MobileUI.h
INCLUDEPATH += $${PWD}

android {
    QT += androidextras
    SOURCES += $${PWD}/MobileUI_android.cpp
} else: ios {
    LIBS += -framework UIKit
    OBJECTIVE_SOURCES += $${PWD}/MobileUI_ios.mm
} else {
    SOURCES += $${PWD}/MobileUI_dummy.cpp
}
