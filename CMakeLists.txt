cmake_minimum_required(VERSION 3.19)

project(WatchFlower VERSION 5.3 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Bluetooth Network Sql)
find_package(Qt6 REQUIRED COMPONENTS Gui Qml Quick QuickControls2 Svg Widgets Charts)

qt_standard_project_setup()

################################################################################

qt_add_executable(WatchFlower
    src/AndroidService.cpp src/AndroidService.h
    src/DatabaseManager.cpp src/DatabaseManager.h
    src/SettingsManager.cpp src/SettingsManager.h
    src/SystrayManager.cpp src/SystrayManager.h
    src/MenubarManager.cpp src/MenubarManager.h
    src/NotificationManager.cpp src/NotificationManager.h
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
    qml/qml.qrc
    qml/components.qrc
    i18n/i18n.qrc
    assets/assets.qrc
    assets/devices.qrc
    assets/plants.qrc
)

target_include_directories(WatchFlower PRIVATE src/)
target_include_directories(WatchFlower PRIVATE src/thirdparty/)

################################################################################

## Android
if(ANDROID)
    set(QT_ANDROID_ABIS "armeabi-v7a;arm64-v8a;x86;x86_64")
    set(QT_ANDROID_BUILD_ALL_ABIS "ON")

    set_target_properties(WatchFlower PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/assets/android"
    )

    target_compile_definitions(WatchFlower PRIVATE QT_CONNECTIVITY_PATCHED)

    target_link_libraries(WatchFlower PRIVATE Qt::CorePrivate)
endif()

## macOS
if(APPLE AND NOT IOS)
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15")
endif()

## iOS
if(IOS)
    target_link_libraries(QmlAppTemplate PRIVATE
        Qt::GuiPrivate
        "-framework UIKit"
    )
endif()

## Windows
if(WIN32)
    target_compile_definitions(WatchFlower PRIVATE _USE_MATH_DEFINES)
endif()

################################################################################

# AppUtils
set(APP_NAME ${CMAKE_PROJECT_NAME})
set(APP_VERSION ${CMAKE_PROJECT_VERSION})
add_subdirectory(src/thirdparty/AppUtils)
target_link_libraries(WatchFlower PRIVATE AppUtils)

# MobileUI
add_subdirectory(src/thirdparty/MobileUI)
target_link_libraries(WatchFlower PRIVATE MobileUI)

# MobileSharing
add_subdirectory(src/thirdparty/MobileSharing)
target_link_libraries(WatchFlower PRIVATE MobileSharing)

# SingleApplication
set(QAPPLICATION_CLASS QApplication)
add_subdirectory(src/thirdparty/SingleApplication)
target_link_libraries(WatchFlower PRIVATE SingleApplication)

# Qt
target_link_libraries(WatchFlower PRIVATE
    Qt::Core
    Qt::Bluetooth
    Qt::Network
    Qt::Sql
    Qt::Gui
    Qt::Qml
    Qt::Quick
    Qt::QuickControls2
    Qt::Svg
    Qt::Widgets
    Qt::Charts
)

################################################################################

if(lupdate_only)
    target_sources(WatchFlower PUBLIC
        qml/*.js qml/*.qml
        qml/components/*.qml
        qml/components_generic/*.qml
        qml/components_js/*.js
    )
endif()

if(CMAKE_BUILD_TYPE STREQUAL Release)
    target_compile_definitions(WatchFlower PRIVATE
        NDEBUG
        QT_NO_DEBUG
        QT_NO_DEBUG_OUTPUT
    )
endif()

set_target_properties(WatchFlower PROPERTIES
    WIN32_EXECUTABLE ON
    MACOSX_BUNDLE ON
)

install(TARGETS WatchFlower
    BUNDLE DESTINATION .    # used by macOS
    ARCHIVE DESTINATION .
    LIBRARY DESTINATION .   # used by Android
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

qt_generate_deploy_qml_app_script(
    TARGET WatchFlower
    FILENAME_VARIABLE deploy_script
    NO_UNSUPPORTED_PLATFORM_ERROR
    DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
    MACOS_BUNDLE_POST_BUILD
)
install(SCRIPT ${deploy_script})

################################################################################

message(STATUS "[PROJECT] CMAKE_VERSION                = ${CMAKE_VERSION}")
message(STATUS "[PROJECT] CMAKE_PREFIX_PATH            = ${CMAKE_PREFIX_PATH}")
message(STATUS "[PROJECT] CMAKE_TOOLCHAIN_FILE         = ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "[DEFINE] SOURCE_DIR                    = ${CMAKE_CURRENT_SOURCE_DIR}")
message(STATUS "[DEFINE] BUILD_TYPE                    = ${CMAKE_BUILD_TYPE}")
message(STATUS "[SYSTEM] HOST SYSTEM NAME              = ${CMAKE_HOST_SYSTEM_NAME}")
message(STATUS "[SYSTEM] (TARGET) SYSTEM NAME          = ${CMAKE_SYSTEM_NAME}")
