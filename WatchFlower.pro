TARGET  = WatchFlower

VERSION = 0.6
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

CONFIG += c++11
QT     += core bluetooth sql
QT     += gui widgets svg qml quick quickcontrols2 charts
android { QT += androidextras }
ios { QT += gui-private }

# Validate Qt version
if (lessThan(QT_MAJOR_VERSION, 5) | lessThan(QT_MINOR_VERSION, 9)) {
    error("You really need AT LEAST Qt 5.9 to build WatchFlower, sorry...")
}
if (lessThan(QT_MINOR_VERSION, 10)) {
    warning("You need Qt 5.10 to build WatchFlower with proper data charts." \
            "You can use Qt 5.9 but you'll need to make a small adjustment into DeviceScreenCharts.qml...")
}

# Build artifacts ##############################################################

OBJECTS_DIR = build/
MOC_DIR     = build/
RCC_DIR     = build/
UI_DIR      = build/
DESTDIR     = bin/

# Project files ################################################################

SOURCES  += src/main.cpp \
            src/settingsmanager.cpp \
            src/systraymanager.cpp \
            src/notificationmanager.cpp \
            src/devicemanager.cpp \
            src/device.cpp \
            src/device_flowercare.cpp \
            src/device_hygrotemp.cpp \
            src/device_ropot.cpp

HEADERS  += src/settingsmanager.h \
            src/systraymanager.h \
            src/notificationmanager.h \
            src/devicemanager.h \
            src/device.h \
            src/device_flowercare.h \
            src/device_hygrotemp.h \
            src/device_ropot.h

RESOURCES   += qml/qml.qrc \
               i18n/i18n.qrc \
               assets/assets.qrc

OTHER_FILES += .travis.yml \
               assets/android/src/com/emeric/watchflower/NotificationDispatcher.java

TRANSLATIONS = i18n/watchflower_fr.ts \
               i18n/watchflower_es.ts i18n/watchflower_gl.ts

lupdate_only { SOURCES += qml/*.qml qml/*.js }

# App features #################################################################

# Use Qt Quick compiler
ios | android { CONFIG += qtquickcompiler }

# Force mobile UI
#DEFINES += FORCE_MOBILE_UI

# StatusBar for mobile OS
include(src/thirdparty/StatusBar/statusbar.pri)

# SingleApplication for desktop OS
include(src/thirdparty/SingleApplication/singleapplication.pri)
DEFINES += QAPPLICATION_CLASS=QApplication

################################################################################
# Application deployment and installation steps

linux:!android {
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
    target_icon.files  += $${OUT_PWD}/assets/desktop/$$lower($${TARGET}).svg
    target_icon.path    = $${PREFIX}/share/pixmaps/
    target_appentry.files  += $${OUT_PWD}/assets/desktop/$$lower($${TARGET}).desktop
    target_appentry.path    = $${PREFIX}/share/applications
    target_appdata.files   += $${OUT_PWD}/assets/desktop/$$lower($${TARGET}).appdata.xml
    target_appdata.path     = $${PREFIX}/share/appdata
    INSTALLS += target_app target_icon target_appentry target_appdata

    # Clean bin/ directory
    #QMAKE_CLEAN += $${OUT_PWD}/$${DESTDIR}/$$lower($${TARGET})
}

macx {
    # OS icon
    ICON = assets/desktop/$$lower($${TARGET}).icns

    # Bundle packaging
    #system(macdeployqt $${OUT_PWD}/$${DESTDIR}/$${TARGET}.app -qmldir=qml/)

    # Automatic bundle packaging
    deploy.commands = macdeployqt $${OUT_PWD}/$${DESTDIR}/$${TARGET}.app -qmldir=qml/
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
    # OS icon
    RC_ICONS = assets/desktop/$$lower($${TARGET}).ico

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
    #x86
    #x86_64
    #armeabi-v7a
    #arm64-v8a
    equals(ANDROID_TARGET_ARCH, "arm64-v8a") {
        #
    }

    ANDROID_PACKAGE_SOURCE_DIR = $${PWD}/assets/android

    DISTFILES += assets/android/AndroidManifest.xml
}

ios {
    #
}
