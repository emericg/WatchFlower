cmake_minimum_required(VERSION 3.20)

project(WatchFlower VERSION 6.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

string(TIMESTAMP CURRENT_TIMESTAMP "%s" UTC)
set(APP_NAME ${CMAKE_PROJECT_NAME})
set(APP_VERSION ${CMAKE_PROJECT_VERSION})
set(APP_VERSION_CODE ${TIMESTAMP})

################################################################################

message(STATUS "[CMAKE] CMAKE_VERSION               = ${CMAKE_VERSION}")
message(STATUS "[CMAKE] CMAKE_PREFIX_PATH           = ${CMAKE_PREFIX_PATH}")
message(STATUS "[SYSTEM] (HOST) SYSTEM NAME         = ${CMAKE_HOST_SYSTEM_NAME}")
message(STATUS "[SYSTEM] (HOST) SYSTEM VERSION      = ${CMAKE_HOST_SYSTEM_VERSION}")
message(STATUS "[SYSTEM] (TARGET) SYSTEM NAME       = ${CMAKE_SYSTEM_NAME}")
message(STATUS "[SYSTEM] (TARGET) SYSTEM VERSION    = ${CMAKE_SYSTEM_VERSION}")
message(STATUS "[PROJECT] SOURCE_DIR                = ${CMAKE_CURRENT_SOURCE_DIR}")
message(STATUS "[PROJECT] BUILD_TYPE                = ${CMAKE_BUILD_TYPE}")
message(STATUS "[PROJECT] TOOLCHAIN_FILE            = ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "[PROJECT] QT_HOST_PATH              = ${QT_HOST_PATH}")

################################################################################

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Bluetooth Network Sql)
find_package(Qt6 6.5 REQUIRED COMPONENTS Gui Qml Quick QuickControls2 Svg Widgets Charts)

qt_standard_project_setup()

set(SOURCES
    src/NotificationManager.cpp src/NotificationManager.h
    src/DatabaseManager.cpp src/DatabaseManager.h
    src/SettingsManager.cpp src/SettingsManager.h
    src/PlantDatabase.cpp src/PlantDatabase.h
    src/Plant.cpp src/Plant.h src/PlantUtils.h
    src/Journal.cpp src/Journal.h
    src/device.cpp src/device.h
    src/device_infos.cpp src/device_infos.h
    src/device_sensor.cpp src/device_sensor_advertisement.cpp src/device_sensor.h
    src/device_plantsensor.cpp src/device_plantsensor.h
    src/device_thermometer.cpp src/device_thermometer.h
    src/device_environmental.cpp src/device_environmental.h
    src/DeviceManager.cpp src/DeviceManager.h
    src/DeviceManager_advertisement.cpp
    src/DeviceManager_nearby.cpp
    src/DeviceManager_export.cpp
    src/DeviceFilter.cpp src/DeviceFilter.h
    src/device_utils.h src/device_firmwares.h
    src/devices/device_flowercare.cpp src/devices/device_flowercare.h
    src/devices/device_flowercare_tuya.cpp src/devices/device_flowercare_tuya.h
    src/devices/device_flowerpower.cpp src/devices/device_flowerpower.h
    src/devices/device_ropot.cpp src/devices/device_ropot.h
    src/devices/device_parrotpot.cpp src/devices/device_parrotpot.h
    src/devices/device_bparasite.cpp src/devices/device_bparasite.h
    src/devices/device_hygrotemp_atc.cpp src/devices/device_hygrotemp_atc.h
    src/devices/device_hygrotemp_cgd1.cpp src/devices/device_hygrotemp_cgd1.h
    src/devices/device_hygrotemp_cgdk2.cpp src/devices/device_hygrotemp_cgdk2.h
    src/devices/device_hygrotemp_cgg1.cpp src/devices/device_hygrotemp_cgg1.h
    src/devices/device_hygrotemp_cgp1w.cpp src/devices/device_hygrotemp_cgp1w.h
    src/devices/device_hygrotemp_clock.cpp src/devices/device_hygrotemp_clock.h
    src/devices/device_hygrotemp_lywsdcgq.cpp src/devices/device_hygrotemp_lywsdcgq.h
    src/devices/device_hygrotemp_square.cpp src/devices/device_hygrotemp_square.h
    src/devices/device_thermobeacon.cpp src/devices/device_thermobeacon.h
    src/devices/device_cgdn1.cpp src/devices/device_cgdn1.h
    src/devices/device_jqjcy01ym.cpp src/devices/device_jqjcy01ym.h
    src/devices/device_wp6003.cpp src/devices/device_wp6003.h
    src/devices/device_esp32_airqualitymonitor.cpp src/devices/device_esp32_airqualitymonitor.h
    src/devices/device_esp32_geigercounter.cpp src/devices/device_esp32_geigercounter.h
    src/devices/device_esp32_higrow.cpp src/devices/device_esp32_higrow.h
    src/devices/device_ess_generic.cpp src/devices/device_ess_generic.h
    src/thirdparty/RC4/rc4.cpp src/thirdparty/RC4/rc4.h
    src/main.cpp
    i18n/i18n.qrc
    qml/qml.qrc
    qml/ComponentLibrary/ComponentLibrary.qrc
    assets/assets.qrc
    assets/icons.qrc
    assets/devices.qrc
    assets/plants.qrc
)
set(SOURCES_ANDROID
    src/AndroidService.cpp src/AndroidService.h
)
if(NOT IOS AND NOT ANDROID)
set(SOURCES_DESKTOP
    src/SystrayManager.cpp src/SystrayManager.h
    src/MenubarManager.cpp src/MenubarManager.h
)
endif()

qt_add_executable(${CMAKE_PROJECT_NAME}
    ${SOURCES}
    ${SOURCES_ANDROID}
    ${SOURCES_DESKTOP}
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE src/)
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE src/thirdparty/)

################################################################################

## Android
if(ANDROID)
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        QT_ANDROID_ABIS "armeabi-v7a;arm64-v8a;x86;x86_64"
        QT_ANDROID_BUILD_ALL_ABIS ON
        QT_ANDROID_MIN_SDK_VERSION 23
        QT_ANDROID_TARGET_SDK_VERSION 34
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/assets/android/"
    )

    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE QT_CONNECTIVITY_PATCHED)

    # Android background service
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE Qt::CorePrivate)
endif()

if(APPLE)
    set(CMAKE_XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.emeric.watchflower.ios")
    set(CMAKE_XCODE_ATTRIBUTE_MARKETING_VERSION "${PROJECT_VERSION}")

    set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")
    set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "")
    set(CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "")
    set(CMAKE_XCODE_ATTRIBUTE_PROVISIONING_PROFILE "")
endif()

## macOS
if(APPLE AND NOT IOS)
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0")
    set(CMAKE_XCODE_ATTRIBUTE_INFOPLIST_FILE "${CMAKE_CURRENT_SOURCE_DIR}/assets/macos/Info.plist")
    set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS "${CMAKE_CURRENT_SOURCE_DIR}/assets/macos/${CMAKE_PROJECT_NAME}.entitlements")
endif()

## iOS
if(IOS)
    set(IPHONEOS_DEPLOYMENT_TARGET "14.0")
    set(CMAKE_OSX_ARCHITECTURES "arm64")
    set(CMAKE_OSX_SYSROOT "iphoneos")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "14.0")
    set(CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "14.0")
    set(CMAKE_XCODE_ATTRIBUTE_INFOPLIST_FILE "${CMAKE_CURRENT_SOURCE_DIR}/assets/ios/Info.plist")
    set(CMAKE_XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2") # iPhone,iPad
endif()

## Windows
if(WIN32)
    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE _USE_MATH_DEFINES)
endif()

################################################################################

# SingleApplication
set(QAPPLICATION_CLASS QApplication)
add_subdirectory(src/thirdparty/SingleApplication)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE SingleApplication)

# AppUtils
add_subdirectory(src/thirdparty/AppUtils)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE AppUtils)

# MobileUI
add_subdirectory(src/thirdparty/MobileUI)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE MobileUI)

# MobileSharing
add_subdirectory(src/thirdparty/MobileSharing)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE MobileSharing)

# Qt
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Bluetooth
    Qt6::Network
    Qt6::Sql
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Svg
    Qt6::Charts
)
if(NOT IOS AND NOT ANDROID)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE
        Qt6::Widgets
    )
endif()

################################################################################

if(lupdate_only)
    target_sources(${CMAKE_PROJECT_NAME} PUBLIC
        qml/*.js qml/*.qml
        qml/components/*.qml
        qml/components_generic/*.qml
        qml/components_js/*.js
    )
endif()

if(CMAKE_BUILD_TYPE STREQUAL Release)
    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE
        NDEBUG
        QT_NO_DEBUG
        QT_NO_DEBUG_OUTPUT
    )
endif()

set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE ON
    WIN32_EXECUTABLE ON
)

install(TARGETS ${CMAKE_PROJECT_NAME}
    BUNDLE DESTINATION .
    ARCHIVE DESTINATION .
    LIBRARY DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

qt_generate_deploy_qml_app_script(
    TARGET ${CMAKE_PROJECT_NAME}
    OUTPUT_SCRIPT deploy_script
    NO_UNSUPPORTED_PLATFORM_ERROR
    DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
    MACOS_BUNDLE_POST_BUILD
)
install(SCRIPT ${deploy_script})

################################################################################
