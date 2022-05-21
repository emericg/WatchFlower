cmake_minimum_required(VERSION 3.16)

project(WatchFlower VERSION 4.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Bluetooth Charts Gui Network Qml Quick QuickControls2 Sql Svg Widgets)

qt_standard_project_setup()

################################################################################

qt_add_executable(WatchFlower
    src/AndroidService.cpp src/AndroidService.h
    src/DatabaseManager.cpp src/DatabaseManager.h
    src/DeviceManager.cpp src/DeviceManager.h
    src/DeviceManager_advertisement.cpp
    src/DeviceManager_nearby.cpp
    src/DeviceManager_export.cpp
    src/Journal.cpp src/Journal.h
    src/NotificationManager.cpp src/NotificationManager.h
    src/Plant.cpp src/Plant.h
    src/PlantDatabase.cpp src/PlantDatabase.h
    src/SettingsManager.cpp src/SettingsManager.h
    src/SystrayManager.cpp src/SystrayManager.h
    src/device.cpp src/device.h
    src/device_filter.cpp src/device_filter.h
    src/device_infos.cpp src/device_infos.h
    src/device_sensor.cpp src/device_sensor.h
    src/device_utils.h
    src/devices/device_esp32_airqualitymonitor.cpp src/devices/device_esp32_airqualitymonitor.h
    src/devices/device_esp32_geigercounter.cpp src/devices/device_esp32_geigercounter.h
    src/devices/device_esp32_higrow.cpp src/devices/device_esp32_higrow.h
    src/devices/device_ess_generic.cpp src/devices/device_ess_generic.h
    src/devices/device_flowercare.cpp src/devices/device_flowercare.h
    src/devices/device_flowerpower.cpp src/devices/device_flowerpower.h
    src/devices/device_hygrotemp_cgd1.cpp src/devices/device_hygrotemp_cgd1.h
    src/devices/device_hygrotemp_cgdk2.cpp src/devices/device_hygrotemp_cgdk2.h
    src/devices/device_hygrotemp_cgg1.cpp src/devices/device_hygrotemp_cgg1.h
    src/devices/device_hygrotemp_cgp1w.cpp src/devices/device_hygrotemp_cgp1w.h
    src/devices/device_hygrotemp_clock.cpp src/devices/device_hygrotemp_clock.h
    src/devices/device_hygrotemp_lywsdcgq.cpp src/devices/device_hygrotemp_lywsdcgq.h
    src/devices/device_hygrotemp_square.cpp src/devices/device_hygrotemp_square.h
    src/devices/device_jqjcy01ym.cpp src/devices/device_jqjcy01ym.h
    src/devices/device_parrotpot.cpp src/devices/device_parrotpot.h
    src/devices/device_ropot.cpp src/devices/device_ropot.h
    src/devices/device_thermobeacon.cpp src/devices/device_thermobeacon.h
    src/devices/device_wp6003.cpp src/devices/device_wp6003.h
    src/thirdparty/MobileSharing/SharingApplication.cpp src/thirdparty/MobileSharing/SharingApplication.h
    src/thirdparty/MobileSharing/SharingUtils.cpp src/thirdparty/MobileSharing/SharingUtils.h
    src/thirdparty/MobileUI/MobileUI.cpp src/thirdparty/MobileUI/MobileUI.h
    src/thirdparty/RC4/rc4.cpp src/thirdparty/RC4/rc4.h
    src/thirdparty/SingleApplication/singleapplication.cpp src/thirdparty/SingleApplication/singleapplication.h src/thirdparty/SingleApplication/singleapplication_p.cpp src/thirdparty/SingleApplication/singleapplication_p.h
    src/utils/utils_app.cpp src/utils/utils_app.h
    src/utils/utils_language.cpp src/utils/utils_language.h
    src/utils/utils_maths.cpp src/utils/utils_maths.h
    src/utils/utils_screen.cpp src/utils/utils_screen.h
    src/utils/utils_versionchecker.h
    src/main.cpp
    qml/qml.qrc
    i18n/i18n.qrc
    assets/assets.qrc
    assets/devices.qrc
    assets/plants.qrc
)

target_include_directories(WatchFlower PRIVATE
    src
    src/thirdparty/MobileSharing
    src/thirdparty/MobileUI
    src/thirdparty/SingleApplication
)

################################################################################

set_target_properties(WatchFlower PROPERTIES
    WIN32_EXECUTABLE ON
    MACOSX_BUNDLE ON
)

target_compile_definitions(WatchFlower PRIVATE
    APP_VERSION=\"4.0\"
    QAPPLICATION_CLASS=QApplication
    QT_DEPRECATED_WARNINGS
)

target_link_libraries(WatchFlower PRIVATE
    Qt::Bluetooth
    Qt::Charts
    Qt::Core
    Qt::Gui
    Qt::Network
    Qt::Qml
    Qt::Quick
    Qt::QuickControls2
    Qt::Sql
    Qt::Svg
    Qt::Widgets
)

################################################################################

## LINUX
if(UNIX AND NOT APPLE AND NOT ANDROID)
    set(LINUX TRUE)
endif()

if(LINUX)
    target_sources(WatchFlower PUBLIC
        src/utils/utils_os_linux.cpp src/utils/utils_os_linux.h
    )

    find_package(Qt6 OPTIONAL_COMPONENTS DBus)
    target_link_libraries(WatchFlower PRIVATE Qt::DBus)
endif()

######## ANDROID
#https://www.qt.io/blog/android-multi-abi-builds-are-back

#-DQT_ANDROID_ABIS="armeabi-v7a;arm64-v8a"
#-DQT_ANDROID_BUILD_ALL_ABIS=ON \
#-DQT_PATH_ANDROID_ABI_armeabi-v7a="<Qt/for/armeabi-v7a>" \
#-DQT_PATH_ANDROID_ABI_arm64-v8a="<Qt/for/arm64-v8a>" \

if(ANDROID)
    target_sources(WatchFlower PUBLIC
        src/thirdparty/MobileSharing/SharingUtils_android.h
        src/thirdparty/MobileSharing/SharingUtils_android_qt6.cpp
        src/thirdparty/MobileUI/MobileUI_android_qt6.cpp
        src/utils/utils_os_android.h src/utils/utils_os_android_qt6.cpp
    )

    target_link_libraries(WatchFlower PRIVATE Qt::CorePrivate)
endif()

## macOS
if(MACOS)
    target_sources(WatchFlower PUBLIC
        src/utils/utils_os_macos.h src/utils/utils_os_macos.mm
        src/utils/utils_os_macosdock.h src/utils/utils_os_macosdock.mm
    )

    #-DCMAKE_OSX_ARCHITECTURES="x86_64;arm64"

    target_link_libraries(WatchFlower PRIVATE
        "-framework AppKit"
        "-framework IOKit"
    )
endif()

## iOS
if(IOS)
    target_link_libraries(WatchFlower PRIVATE
        "-framework Qt::GuiPrivate"
        "-framework UIKit"
    )

    target_sources(WatchFlower PUBLIC
        src/thirdparty/MobileSharing/SharingUtils_ios.h src/thirdparty/MobileSharing/SharingUtils_ios.mm
        src/thirdparty/MobileSharing/docviewcontroller_ios.h src/thirdparty/MobileSharing/docviewcontroller_ios.mm
        src/thirdparty/MobileUI/MobileUI_ios.mm
        src/utils/utils_os_ios.h src/utils/utils_os_ios.mm
    )
endif()

## Windows
if(WIN32)
    target_sources(WatchFlower PUBLIC
        src/utils/utils_os_windows.cpp src/utils/utils_os_windows.h
    )

    target_compile_definitions(WatchFlower PRIVATE _USE_MATH_DEFINES)

    if(MSVC)
        target_link_libraries(WatchFlower PRIVATE Advapi32.lib )
    endif()
    if(GCC)
        target_link_libraries(WatchFlower PRIVATE advapi32 )
    endif()
endif()









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

if(NOT ANDROID AND NOT IOS)
    target_sources(WatchFlower PUBLIC
        src/thirdparty/MobileUI/MobileUI_dummy.cpp
    )
endif()

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

if(WIN32)
    set(date_command "CMD")
    set(date_arg "/c date /t")
else
    set(date_command "date")
    set(date_arg "")
endif()

execute_process(
    COMMAND ${date_command} ${date_arg}
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE BUILD_DATE
    OUTPUT_STRIP_TRAILING_WHITESPACE)

find_package(Git REQUIRED)

execute_process(
    COMMAND "${GIT_EXECUTABLE}" describe --always
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE GIT_COMMIT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE)

message(STATUS "[SYSTEM] HOST SYSTEM                   = ${CMAKE_HOST_SYSTEM_NAME}")
message(STATUS "[SYSTEM] TARGET PLATFORM               = ${CMAKE_SYSTEM_NAME}")
message(STATUS "[DEFINE] SOURCE_DIR                    = ${CMAKE_CURRENT_SOURCE_DIR}")
message(STATUS "[DEFINE] BUILD_TYPE                    = ${CMAKE_BUILD_TYPE}")
message(STATUS "[DEFINE] BUILD_DATE                    = ${BUILD_DATE}")
message(STATUS "[DEFINE] GIT_COMMIT_HASH               = ${GIT_COMMIT_HASH}")
message(STATUS "[PROJECT] CMAKE_TOOLCHAIN_FILE         = ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "[PROJECT] CMAKE_PREFIX_PATH            = ${CMAKE_PREFIX_PATH}")
message(STATUS "[PROJECT] CMAKE_VERSION                = ${CMAKE_VERSION}")
