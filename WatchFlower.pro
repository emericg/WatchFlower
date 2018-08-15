TARGET  = WatchFlower
VERSION = 0.4.0

CONFIG += c++11
QT     += core bluetooth sql
QT     += gui widgets svg qml quick quickcontrols2 charts

# Pass app version to the C++
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

# Validate Qt version
if (lessThan(QT_MAJOR_VERSION, 5) | lessThan(QT_MINOR_VERSION, 7)) {
    error("You really need Qt 5.7 to build WatchFlower, sorry...")
}
if (lessThan(QT_MINOR_VERSION, 10)) {
    warning("You need Qt 5.10 to build WatchFlower with proper data charts." \
            "You can use Qt 5.7 but you'll need to make a small adjustment into DeviceScreenCharts.qml...")
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
            src/systraymanager.cpp \
            src/devicemanager.cpp \
            src/device.cpp

HEADERS  += src/settingsmanager.h \
            src/systraymanager.h \
            src/devicemanager.h \
            src/device.h

OTHER_FILES += qml/*.qml

RESOURCES   += qml/qml.qrc assets/assets.qrc

include(src/thirdparty/SingleApplication/singleapplication.pri)
DEFINES += QAPPLICATION_CLASS=QApplication

# OS icons (macOS and Windows)
ICON         = assets/app/$$lower($${TARGET}).icns
RC_ICONS     = assets/app/$$lower($${TARGET}).ico

# Application deployment and installation steps
linux {
    TARGET = $$lower($${TARGET})

    # Application packaging # Needs linuxdeployqt installed
    #system(linuxdeployqt $${OUT_PWD}/$${DESTDIR}/ -qmldir=qml/)

    # Application packaging # Needs linuxdeployqt installed
    #deploy.commands = $${OUT_PWD}/$${DESTDIR}/ -qmldir=qml/
    #install.depends = deploy
    #QMAKE_EXTRA_TARGETS += install deploy

    # Installation
    isEmpty(PREFIX) { PREFIX = /usr/local }
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
    #QMAKE_CLEAN += $${OUT_PWD}/$${DESTDIR}/$$lower($${TARGET})
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

android {
    equals(ANDROID_TARGET_ARCH, "") {
        #armeabi-v7a
        #arm64-v8a
    }
    equals(ANDROID_TARGET_ARCH, "") {
        #x86
        #x86_64
    }
}
