TARGET      = WatchFlower
CONFIG     += c++11

QT += core bluetooth sql
QT += gui widgets quick charts

# Build artifacts
OBJECTS_DIR = build/
MOC_DIR     = build/
DESTDIR     = bin/

# Project files
SOURCES  += src/main.cpp \
            src/devicemanager.cpp \
            src/device.cpp

HEADERS  += src/devicemanager.h \
            src/device.h

OTHER_FILES += qml/*.qml

RESOURCES   += resources.qrc

# OS icons (macOS and Windows)
ICON         = assets/app/icon.icns
RC_ICONS     = assets/app/icon.ico

# Deployment
linux {
    # System installation
    #target.files += $$OUT_PWD/$${DESTDIR}/$${TARGET}
    #target.path = /usr/local/bin/
    #INSTALLS += target
}

macx {
    # 'automatic' bundle packaging
    #system(macdeployqt $$OUT_PWD/$${DESTDIR}/$${TARGET}.app)
    #QMAKE_POST_LINK += $$quote(macdeployqt $$OUT_PWD/$${DESTDIR}/$${TARGET}.app)

    # System installation
    #target.files += $${OUT_PWD}/${DESTDIR}/${TARGET}.app
    #target.path = ~/Applications
    #INSTALLS += target
}

win32 {
    # 'automatic' application packaging
    #system(windeployqt $$OUT_PWD/$${DESTDIR}/)
    #QMAKE_POST_LINK += $$quote(windeployqt $$OUT_PWD/$${DESTDIR}/)
}
