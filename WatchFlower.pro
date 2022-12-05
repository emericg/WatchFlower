TARGET  = WatchFlower

VERSION = 5.0
DEFINES+= APP_NAME=\\\"$$TARGET\\\"
DEFINES+= APP_VERSION=\\\"$$VERSION\\\"

CONFIG += c++17
QT     += core bluetooth sql
QT     += qml quick quickcontrols2 svg widgets charts

# Validate Qt version
!versionAtLeast(QT_VERSION, 6.3) : error("You need at least Qt version 6.3 for $${TARGET}")

# Project features #############################################################

# MobileUI and MobileSharing for mobile OS
include(src/thirdparty/MobileUI/MobileUI.pri)
include(src/thirdparty/MobileSharing/MobileSharing.pri)

# SingleApplication for desktop OS
include(src/thirdparty/SingleApplication/SingleApplication.pri)
DEFINES += QAPPLICATION_CLASS=QApplication

# Various utils
include(src/thirdparty/AppUtils/AppUtils.pri)

# Better handling of Bluetooth in the background
#android { DEFINES += QT_CONNECTIVITY_PATCHED }

# Project files ################################################################

SOURCES  += src/main.cpp \
            src/SettingsManager.cpp \
            src/DatabaseManager.cpp \
            src/SystrayManager.cpp \
            src/MenubarManager.cpp \
            src/NotificationManager.cpp \
            src/AndroidService.cpp \
            src/PlantDatabase.cpp \
            src/Plant.cpp \
            src/Journal.cpp \
            src/DeviceManager.cpp \
            src/DeviceManager_advertisement.cpp \
            src/DeviceManager_nearby.cpp \
            src/DeviceManager_export.cpp \
            src/DeviceFilter.cpp \
            src/device.cpp \
            src/device_infos.cpp \
            src/device_sensor.cpp \
            src/device_plantsensor.cpp \
            src/device_thermometer.cpp \
            src/device_environmental.cpp \
            src/devices/device_flowercare.cpp \
            src/devices/device_flowercare_tuya.cpp \
            src/devices/device_flowerpower.cpp \
            src/devices/device_ropot.cpp \
            src/devices/device_parrotpot.cpp \
            src/devices/device_hygrotemp_cgd1.cpp \
            src/devices/device_hygrotemp_cgdk2.cpp \
            src/devices/device_hygrotemp_cgg1.cpp \
            src/devices/device_hygrotemp_cgp1w.cpp \
            src/devices/device_hygrotemp_clock.cpp \
            src/devices/device_hygrotemp_square.cpp \
            src/devices/device_hygrotemp_lywsdcgq.cpp \
            src/devices/device_thermobeacon.cpp \
            src/devices/device_cgdn1.cpp \
            src/devices/device_jqjcy01ym.cpp \
            src/devices/device_wp6003.cpp \
            src/devices/device_esp32_airqualitymonitor.cpp \
            src/devices/device_esp32_geigercounter.cpp \
            src/devices/device_esp32_higrow.cpp \
            src/devices/device_ess_generic.cpp \
            src/thirdparty/RC4/rc4.cpp

HEADERS  += src/SettingsManager.h \
            src/DatabaseManager.h \
            src/MenubarManager.h \
            src/SystrayManager.h \
            src/NotificationManager.h \
            src/AndroidService.h \
            src/PlantDatabase.h \
            src/Plant.h \
            src/Journal.h \
            src/DeviceManager.h \
            src/DeviceFilter.h \
            src/device.h \
            src/device_utils.h \
            src/device_firmwares.h \
            src/device_infos.h \
            src/device_sensor.h \
            src/device_plantsensor.h \
            src/device_thermometer.h \
            src/device_environmental.h \
            src/devices/device_flowercare.h \
            src/devices/device_flowercare_tuya.h \
            src/devices/device_flowerpower.h \
            src/devices/device_ropot.h \
            src/devices/device_parrotpot.h \
            src/devices/device_hygrotemp_cgd1.h \
            src/devices/device_hygrotemp_cgdk2.h \
            src/devices/device_hygrotemp_cgg1.h \
            src/devices/device_hygrotemp_cgp1w.h \
            src/devices/device_hygrotemp_clock.h \
            src/devices/device_hygrotemp_square.h \
            src/devices/device_hygrotemp_lywsdcgq.h \
            src/devices/device_thermobeacon.h \
            src/devices/device_cgdn1.h \
            src/devices/device_jqjcy01ym.h \
            src/devices/device_wp6003.h \
            src/devices/device_esp32_airqualitymonitor.h \
            src/devices/device_esp32_geigercounter.h \
            src/devices/device_esp32_higrow.h \
            src/devices/device_ess_generic.h \
            src/thirdparty/RC4/rc4.h

INCLUDEPATH += src/ src/thirdparty/

RESOURCES   += qml/qml.qrc \
               qml/components.qrc \
               i18n/i18n.qrc \
               assets/assets.qrc \
               assets/devices.qrc \
               assets/plants.qrc

OTHER_FILES += README.md \
               deploy_linux.sh \
               deploy_macos.sh \
               deploy_windows.sh \
               .github/workflows/builds_desktop.yml \
               .github/workflows/builds_mobile.yml \
               .github/workflows/flatpak.yml \
               .gitignore

TRANSLATIONS = i18n/watchflower_ca.ts \
               i18n/watchflower_da.ts \
               i18n/watchflower_de.ts \
               i18n/watchflower_en.ts \
               i18n/watchflower_es.ts \
               i18n/watchflower_fr.ts \
               i18n/watchflower_fy.ts \
               i18n/watchflower_nb.ts \
               i18n/watchflower_nl.ts \
               i18n/watchflower_nn.ts \
               i18n/watchflower_pt_BR.ts \
               i18n/watchflower_ru.ts \
               i18n/watchflower_zh_CN.ts \
               i18n/watchflower_zh_TW.ts

lupdate_only {
    SOURCES += qml/*.qml qml/*.js \
               qml/components/*.qml qml/components_generic/*.qml qml/components_js/*.js
}

# Build settings ###############################################################

ios | android { CONFIG += qtquickcompiler }

win32 { DEFINES += _USE_MATH_DEFINES }

DEFINES += QT_DEPRECATED_WARNINGS

CONFIG(release, debug|release) : DEFINES += NDEBUG QT_NO_DEBUG QT_NO_DEBUG_OUTPUT

unix {
    # Enables AddressSanitizer
    #QMAKE_CXXFLAGS += -fsanitize=address,undefined
    #QMAKE_CXXFLAGS += -Wno-nullability-completeness
    #QMAKE_LFLAGS += -fsanitize=address,undefined
}

# Build artifacts ##############################################################

OBJECTS_DIR = build/$${QT_ARCH}/
MOC_DIR     = build/$${QT_ARCH}/
RCC_DIR     = build/$${QT_ARCH}/
UI_DIR      = build/$${QT_ARCH}/

DESTDIR     = bin/

################################################################################
# Application deployment and installation steps

linux:!android {
    TARGET = $$lower($${TARGET})

    # Automatic application packaging # Needs linuxdeployqt installed
    #system(linuxdeployqt $${OUT_PWD}/$${DESTDIR}/ -qmldir=qml/)

    # Application packaging # Needs linuxdeployqt installed
    #deploy.commands = $${OUT_PWD}/$${DESTDIR}/ -qmldir=qml/
    #install.depends = deploy
    #QMAKE_EXTRA_TARGETS += install deploy

    # Installation steps
    isEmpty(PREFIX) { PREFIX = /usr/local }
    target_app.files       += $${OUT_PWD}/$${DESTDIR}/$$lower($${TARGET})
    target_app.path         = $${PREFIX}/bin/
    target_appentry.files  += $${OUT_PWD}/assets/linux/$$lower($${TARGET}).desktop
    target_appentry.path    = $${PREFIX}/share/applications
    target_appdata.files   += $${OUT_PWD}/assets/linux/$$lower($${TARGET}).appdata.xml
    target_appdata.path     = $${PREFIX}/share/appdata
    target_icon_appimage.files += $${OUT_PWD}/assets/linux/$$lower($${TARGET}).svg
    target_icon_appimage.path   = $${PREFIX}/share/pixmaps/
    target_icon_flatpak.files  += $${OUT_PWD}/assets/linux/$$lower($${TARGET}).svg
    target_icon_flatpak.path    = $${PREFIX}/share/icons/hicolor/scalable/apps/
    INSTALLS += target_app target_appentry target_appdata target_icon_appimage target_icon_flatpak

    # Clean appdir/ and bin/ directories
    #QMAKE_CLEAN += $${OUT_PWD}/$${DESTDIR}/$$lower($${TARGET})
    #QMAKE_CLEAN += $${OUT_PWD}/appdir/
}

macx {
    # Bundle name
    QMAKE_TARGET_BUNDLE_PREFIX = com.emeric
    QMAKE_BUNDLE = watchflower

    # OS icons
    ICON = $${PWD}/assets/macos/$$lower($${TARGET}).icns
    #QMAKE_ASSET_CATALOGS_APP_ICON = "AppIcon"
    #QMAKE_ASSET_CATALOGS = $${PWD}/assets/macos/Images.xcassets

    # OS infos
    QMAKE_INFO_PLIST = $${PWD}/assets/macos/Info.plist

    # OS entitlement (sandbox and stuff)
    ENTITLEMENTS.name = CODE_SIGN_ENTITLEMENTS
    ENTITLEMENTS.value = $${PWD}/assets/macos/$$lower($${TARGET}).entitlements
    QMAKE_MAC_XCODE_SETTINGS += ENTITLEMENTS

    # Target architecture(s)
    QMAKE_APPLE_DEVICE_ARCHS = x86_64 arm64

    # Target OS
    QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.14

    #======== Automatic bundle packaging

    # Deploy step (app bundle packaging)
    deploy.commands = macdeployqt $${OUT_PWD}/$${DESTDIR}/$${TARGET}.app -qmldir=qml/ -appstore-compliant
    install.depends = deploy
    QMAKE_EXTRA_TARGETS += install deploy

    # Installation step (note: app bundle packaging)
    isEmpty(PREFIX) { PREFIX = /usr/local }
    target.files += $${OUT_PWD}/${DESTDIR}/${TARGET}.app
    target.path = $$(HOME)/Applications
    INSTALLS += target

    # Clean step
    QMAKE_DISTCLEAN += -r $${OUT_PWD}/${DESTDIR}/${TARGET}.app

    #======== XCode

    # macOS developer settings
    exists($${PWD}/assets/macos/macos_signature.pri) {
        # Must contain values for:
        # QMAKE_DEVELOPMENT_TEAM
        # QMAKE_PROVISIONING_PROFILE
        # QMAKE_XCODE_CODE_SIGN_IDENTITY (optional)
        include($${PWD}/assets/macos/macos_signature.pri)
    }

    # Paths and folders
    QT_BIN_PATH = $$dirname(QMAKE_QMAKE)
    QT_PLUGINS_FOLDER = $$dirname(QT_BIN_PATH)/plugins
    QT_PATH = $$dirname(QT_BIN_PATH)

    # 'xcodeproj' rule / Generate xcode project file
    xcodeproj.commands = export CUSTOM_ENV_VAR=34
    xcodeproj.commands += && $$QMAKE_QMAKE -spec macx-xcode $$PWD/$${TARGET}.pro \
        -o $$OUT_PWD/ CONFIG+=$$BUILD_TYPE CONFIG+=release QMAKE_INCDIR_QT=$$QT_PATH/include \
        QMAKE_LIBDIR=$$QT_PATH/lib QMAKE_MOC=$$QT_PATH/bin/moc QMAKE_QMAKE=$$QT_PATH/bin/qmake
    QMAKE_EXTRA_TARGETS += xcodeproj

    # 'xcodedeploy' rule / Bundle packaging from XCode archive
    CONFIG(release, debug|release): {
        # Get the absolute directory path for XCode archives folder
        XCODE_ARCHIVES_DIRECTORY = $$system(echo ~/Library/Developer/Xcode/Archives)/$$system(date +%Y-%m-%d)
        # Get the newest file that starts with the target name
        XCODE_ARCHIVE_NAME = $$system(cd $$XCODE_ARCHIVES_DIRECTORY && ls | grep -e $${TARGET}* | sort -n -t _ -k 2 | tail -1)
        # This will be the absolute path to the app bundle
        DEPLOYED_APP_PATH = ""
        # If the variable is set to something, it means that we found our archive file
        !isEmpty(XCODE_ARCHIVE_NAME) {
            DEPLOYED_APP_PATH = $$XCODE_ARCHIVES_DIRECTORY/$$XCODE_ARCHIVE_NAME/Products/Applications/$${TARGET}.app
            EXISTS_RESULT = $$system([ ! -e $$quote(\"$$DEPLOYED_APP_PATH\") ] && echo "false" || echo "true")
            # If the archive file doesn't exist, we are going to use the app bunlde in the build directory
            equals(EXISTS_RESULT, false) {
                xcodedeploy.depends += all
                DEPLOYED_APP_PATH = $${OUT_PWD}/$${TARGET}.app
            } else {
                DEPLOYED_APP_PATH = $$quote(\"$$DEPLOYED_APP_PATH\")
            }
        } else {
            warning("Cannot find xcode archive")
            ## Since we cannot find the file, we need to make sure that the project is built so that the app bundle is created
            #xcodedeploy.depends += all
            #DEPLOYED_APP_PATH = $$OUT_PWD/$${TARGET}.app
        }

        BUNDLE_PLUGINS_FOLDER = $$DEPLOYED_APP_PATH/Contents/Plugins

        # The xcodedeploy target runs macdeployqt and removes the unsed files from the bundle
        # Signing is handled by XCode when uploading to the App Store
        xcodedeploy.commands = $$QT_BIN_PATH/macdeployqt $$DEPLOYED_APP_PATH -qmldir=$${PWD}/qml -appstore-compliant

        # dSYM files are bundled with a different bundle ID than the app id and they are rejected by the App Store
        xcodedeploy.commands += && find $$DEPLOYED_APP_PATH/ -name $$quote(\"*.dSYM\") -exec rm -rf -d -f {} +

        QMAKE_EXTRA_TARGETS += xcodedeploy
    }
}

win32 {
    # OS icon
    RC_ICONS = $${PWD}/assets/windows/$$lower($${TARGET}).ico

    # Deploy step
    deploy.commands = $$quote(windeployqt $${OUT_PWD}/$${DESTDIR}/ --qmldir qml/)
    install.depends = deploy
    QMAKE_EXTRA_TARGETS += install deploy

    # Installation step
    # TODO

    # Clean step
    # TODO
}

android {
    # ANDROID_TARGET_ARCH: [x86_64, armeabi-v7a, arm64-v8a]
    #message("ANDROID_TARGET_ARCH: $$ANDROID_TARGET_ARCH")

    # Bundle name
    QMAKE_TARGET_BUNDLE_PREFIX = com.emeric
    QMAKE_BUNDLE = watchflower

    OTHER_FILES += $${PWD}/assets/android/src/com/emeric/watchflower/WatchFlowerBootServiceBroadcastReceiver.java \
                   $${PWD}/assets/android/src/com/emeric/watchflower/WatchFlowerAndroidService.java \
                   $${PWD}/assets/android/src/com/emeric/watchflower/WatchFlowerAndroidNotifier.java \
                   $${PWD}/assets/android/src/com/emeric/utils/QShareUtils.java \
                   $${PWD}/assets/android/src/com/emeric/utils/QSharePathResolver.java

    DISTFILES += $${PWD}/assets/android/AndroidManifest.xml \
                 $${PWD}/assets/android/gradle.properties \
                 $${PWD}/assets/android/build.gradle

    ANDROID_PACKAGE_SOURCE_DIR = $${PWD}/assets/android
}

ios {
    #QMAKE_IOS_DEPLOYMENT_TARGET = 11.0
    #message("QMAKE_IOS_DEPLOYMENT_TARGET: $$QMAKE_IOS_DEPLOYMENT_TARGET")

    CONFIG += no_autoqmake

    # Bundle name
    QMAKE_TARGET_BUNDLE_PREFIX = com.emeric.ios
    QMAKE_BUNDLE = watchflower

    # OS infos
    QMAKE_INFO_PLIST = $${PWD}/assets/ios/Info.plist
    QMAKE_APPLE_TARGETED_DEVICE_FAMILY = 1,2 # 1: iPhone / 2: iPad / 1,2: Universal

    # OS icons
    QMAKE_ASSET_CATALOGS_APP_ICON = "AppIcon"
    QMAKE_ASSET_CATALOGS = $${PWD}/assets/ios/Images.xcassets

    # iOS launch screen
    AppLaunchScreen.files += $${PWD}/assets/ios/AppLaunchScreen.storyboard
    QMAKE_BUNDLE_DATA += AppLaunchScreen

    # iOS developer settings
    exists($${PWD}/assets/ios/ios_signature.pri) {
        # Must contain values for:
        # QMAKE_DEVELOPMENT_TEAM
        # QMAKE_PROVISIONING_PROFILE
        include($${PWD}/assets/ios/ios_signature.pri)
    }
}
