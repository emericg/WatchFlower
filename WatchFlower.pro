TARGET  = WatchFlower
VERSION = 0.1.1

CONFIG += c++11
QT     += core bluetooth sql
QT     += gui widgets quick charts

# Validate Qt version
if (lessThan(QT_MAJOR_VERSION, 5) | lessThan(QT_MINOR_VERSION, 7)) {
    error("You really need Qt 5.7 to build WatchFlower, sorry...")
}
if (lessThan(QT_MINOR_VERSION, 10)) {
    warning("You need Qt 5.10 to build WatchFlower with proper data charts." \
            "You can use Qt 5.7 but you'll need to make a small adjustment into ChartBox.qml...")
}

# Build artifacts
OBJECTS_DIR = build/
MOC_DIR     = build/
RCC_DIR     = build/
UI_DIR      = build/
DESTDIR     = bin/

# Project files
SOURCES  += src/main.cpp \
            src/settingsmanager.cpp \
            src/devicemanager.cpp \
            src/device.cpp

HEADERS  += src/settingsmanager.h \
            src/devicemanager.h \
            src/device.h

OTHER_FILES += qml/*.qml

RESOURCES   += resources.qrc

# OS icons (macOS and Windows)
ICON         = assets/app/watchflower.icns
RC_ICONS     = assets/app/watchflower.ico

# Application deployment and installation steps
linux {
    # Installation
    isEmpty(PREFIX) { PREFIX = /usr/local }
    target_app.extra    = cp $${OUT_PWD}/$${DESTDIR}/$${TARGET} $${OUT_PWD}/$${DESTDIR}/$$lower($${TARGET})
    target_app.files   += $${OUT_PWD}/$${DESTDIR}/$$lower($${TARGET})
    target_app.path     = $${PREFIX}/bin/
    target_icon.files  += $${OUT_PWD}/assets/app/$$lower($${TARGET}).svg
    target_icon.path    = $${PREFIX}/share/pixmaps/
    target_appentry.files  += $${OUT_PWD}/assets/app/$$lower($${TARGET}).desktop
    target_appentry.path    = $${PREFIX}/share/applications
    target_appdata.files   += $${OUT_PWD}/assets/app/$$lower($${TARGET}).appdata.xml
    target_appdata.path     = $${PREFIX}/share/appdata
    INSTALLS += target_app target_icon target_appentry target_appdata

    # Clean bin/ directory
    QMAKE_CLEAN += $${OUT_PWD}/$${DESTDIR}/$$lower($${TARGET})
}

macx {
    # Bundle packaging
    #system(macdeployqt $${OUT_PWD}/$${DESTDIR}/$${TARGET}.app)

    # Automatic bundle packaging
    deploy.commands = macdeployqt $${OUT_PWD}/$${DESTDIR}/$${TARGET}.app
    install.depends = deploy
    QMAKE_EXTRA_TARGETS += install deploy

    # Installation
    target.files += $${OUT_PWD}/${DESTDIR}/${TARGET}.app
    target.path = $$(HOME)/Applications
    INSTALLS += target

    # Clean bin/ directory
    QMAKE_DISTCLEAN += -r $${OUT_PWD}/${DESTDIR}/${TARGET}.app
}

win32 {
    # Application packaging
    #system(windeployqt $${OUT_PWD}/$${DESTDIR}/ --qmldir qml/)

    # Automatic application packaging
    deploy.commands = $$quote(windeployqt $${OUT_PWD}/$${DESTDIR}/ --qmldir qml/)
    install.depends = deploy
    QMAKE_EXTRA_TARGETS += install deploy

    # Installation
    # TODO?

    # Clean bin/ directory
    # TODO
}
