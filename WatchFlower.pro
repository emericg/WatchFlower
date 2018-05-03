TARGET       = WatchFlower
CONFIG      += c++11

QT += core gui widgets sql
QT += quick charts bluetooth

# build artifacts
OBJECTS_DIR = build/
MOC_DIR     = build/
DESTDIR     = bin/

SOURCES += src/main.cpp \
           src/devicemanager.cpp \
           src/device.cpp

HEADERS += src/devicemanager.h \
           src/device.h

OTHER_FILES += qml/*.qml

RESOURCES += resources.qrc

# OS icons (macOS and Windows)
#ICON         = resources/icon.icns
#RC_ICONS     = resources/icon.ico
#QMAKE_INFO_PLIST = resources/Info.plist

#target.path = WatchFlower/
#INSTALLS += target
