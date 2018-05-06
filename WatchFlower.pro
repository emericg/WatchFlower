TARGET      = WatchFlower
CONFIG     += c++11

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

#target.path = WatchFlower/
#INSTALLS += target
ICON         = assets/app/icon.icns
RC_ICONS     = assets/app/icon.ico
