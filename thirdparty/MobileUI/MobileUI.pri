QT += core gui qml

SOURCES += $${PWD}/MobileUI.cpp

HEADERS += $${PWD}/MobileUI.h \
           $${PWD}/MobileUI_private.h

INCLUDEPATH += $${PWD}

android {
    SOURCES += $${PWD}/MobileUI_android.cpp
} else: ios {
    LIBS += -framework UIKit
    SOURCES += $${PWD}/MobileUI_ios.mm
} else {
    SOURCES += $${PWD}/MobileUI_dummy.cpp
}
