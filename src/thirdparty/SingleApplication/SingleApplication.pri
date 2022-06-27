QT += core network
CONFIG += c++11

SOURCES += $${PWD}/singleapplication.cpp \
           $${PWD}/singleapplication_p.cpp

HEADERS += $${PWD}/SingleApplication \
           $${PWD}/singleapplication.h \
           $${PWD}/singleapplication_p.h

INCLUDEPATH += $${PWD}

win32 {
    msvc: LIBS += Advapi32.lib
    gcc: LIBS += -ladvapi32
}
