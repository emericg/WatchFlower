TARGET  = WatchFlower

VERSION = 0.8
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

CONFIG += c++11
QT     += core bluetooth sql
QT     += qml quickcontrols2 charts svg
android { QT += androidextras }
ios { QT += gui-private }

# Validate Qt version
if (lessThan(QT_MAJOR_VERSION, 5) | lessThan(QT_MINOR_VERSION, 10)) {
    error("You really need AT LEAST Qt 5.10 to build WatchFlower, sorry...")
}

# Build artifacts ##############################################################

OBJECTS_DIR = build/
MOC_DIR     = build/
RCC_DIR     = build/
UI_DIR      = build/
QMLCACHE_DIR= build/
DESTDIR     = bin/

# Project files ################################################################

SOURCES  += src/main.cpp \
            src/settingsmanager.cpp \
            src/systraymanager.cpp \
            src/notificationmanager.cpp \
            src/devicemanager.cpp \
            src/device.cpp \
            src/device_flowercare.cpp \
            src/device_hygrotemp_lcd.cpp \
            src/device_hygrotemp_eink.cpp \
            src/device_hygrotemp_clock.cpp \
            src/device_ropot.cpp

HEADERS  += src/settingsmanager.h \
            src/systraymanager.h \
            src/versionchecker.h \
            src/notificationmanager.h \
            src/devicemanager.h \
            src/device.h \
            src/device_flowercare.h \
            src/device_hygrotemp_lcd.h \
            src/device_hygrotemp_eink.h \
            src/device_hygrotemp_clock.h \
            src/device_ropot.h

RESOURCES   += qml/qml.qrc \
               i18n/i18n.qrc \
               assets/assets.qrc

OTHER_FILES += .travis.yml \
               assets/android/src/com/emeric/watchflower/NotificationDispatcher.java

TRANSLATIONS = i18n/watchflower_fr.ts \
               i18n/watchflower_es.ts i18n/watchflower_gl.ts

lupdate_only { SOURCES += qml/*.qml qml/*.js qml/components/*.qml qml/components_themed/*.qml }

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
    #QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.12
    #message("QMAKE_MACOSX_DEPLOYMENT_TARGET: $$QMAKE_MACOSX_DEPLOYMENT_TARGET")

    # OS icon
    ICON = assets/desktop/$$lower($${TARGET}).icns

    # Bundle packaging
    #system(macdeployqt $${OUT_PWD}/$${DESTDIR}/$${TARGET}.app -qmldir=qml/)

    # Automatic bundle packaging
    deploy.commands = macdeployqt $${OUT_PWD}/$${DESTDIR}/$${TARGET}.app -qmldir=qml/ -appstore-compliant
    install.depends = deploy
    QMAKE_EXTRA_TARGETS += install deploy

    # Installation (require deploy step)
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
    # ANDROID_TARGET_ARCH: [x86_64, armeabi-v7a, arm64-v8a]
    #message("ANDROID_TARGET_ARCH: $$ANDROID_TARGET_ARCH")

    ANDROID_PACKAGE_SOURCE_DIR = $${PWD}/assets/android
    DISTFILES += $${PWD}/assets/android/AndroidManifest.xml
}

ios {
    #QMAKE_IOS_DEPLOYMENT_TARGET = 11.0
    #message("QMAKE_IOS_DEPLOYMENT_TARGET: $$QMAKE_IOS_DEPLOYMENT_TARGET")

    QMAKE_ASSET_CATALOGS = $$PWD/assets/ios/Images.xcassets
    QMAKE_ASSET_CATALOGS_APP_ICON = "AppIcon"

    #QMAKE_INFO_PLIST = $$PWD/assets/ios/Info.plist

    # 1: iPhone / 2: iPad / 1,2: Universal
    QMAKE_APPLE_TARGETED_DEVICE_FAMILY = 1,2

    QMAKE_TARGET_BUNDLE_PREFIX = com.emeric.ios
    QMAKE_BUNDLE = watchflower

    # iOS developer settings
    exists($${PWD}/assets/ios/ios_signature.pri) {
        # the file must contains values for:
        # QMAKE_XCODE_CODE_SIGN_IDENTITY
        # QMAKE_DEVELOPMENT_TEAM
        # QMAKE_PROVISIONING_PROFILE
        include($${PWD}/assets/ios/ios_signature.pri)
    }
}
