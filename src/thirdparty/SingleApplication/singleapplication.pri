QT += core network
CONFIG += c++11

INCLUDEPATH += $${PWD}

HEADERS += $${PWD}/singleapplication.h \
           $${PWD}/singleapplication_p.h

SOURCES += $${PWD}/singleapplication.cpp \
           $${PWD}/singleapplication_p.cpp

win32 {
    msvc:LIBS += Advapi32.lib
    gcc:LIBS += -ladvapi32
}
