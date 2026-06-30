cmake_minimum_required(VERSION 3.20)

project(MobileSharing LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_NO_PRIVATE_MODULE_WARNING ON)

################################################################################

# Generic dependencies
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml)
set(CORE_LIBRARIES Qt::Core Qt::Gui Qt::Qml)

# Generic sources
set(CORE_SOURCES
    MobileSharing.cpp MobileSharing.h MobileSharing_private.h
    MobileSharing_DocumentProvider.cpp MobileSharing_DocumentProvider.h
    MobileSharing_QmlDispatcher.cpp MobileSharing_QmlDispatcher.h)

# OS specific sources & dependencies
if (ANDROID)
    set(PLATFORM_SOURCES
        MobileSharing_android.cpp MobileSharing_android.h)

    if(Qt6Gui_VERSION VERSION_GREATER_EQUAL 6.10.0)
        find_package(Qt6 REQUIRED COMPONENTS CorePrivate)
        set(PLATFORM_LIBRARIES ${CORE_LIBRARIES} Qt6::CorePrivate)
    else()
        find_package(Qt6 REQUIRED COMPONENTS Core)
        set(PLATFORM_LIBRARIES ${CORE_LIBRARIES} Qt6::CorePrivate)
    endif()
elseif (IOS)
    enable_language(OBJCXX)
    set(PLATFORM_SOURCES
        MobileSharing_ios.mm)

    set(PLATFORM_LIBRARIES
        "-framework UIKit"
        "-framework Foundation"
        "-framework QuickLook"
        "-framework UniformTypeIdentifiers")
endif()

################################################################################

qt_add_library(MobileSharing STATIC)

qt_add_qml_module(MobileSharing
    URI MobileSharing
    VERSION 1.0
    DEPENDENCIES QtQuick
    PLUGIN_TARGET MobileSharing_plugin
    SOURCES ${CORE_SOURCES} ${PLATFORM_SOURCES}
    #OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml/MobileSharing"
)

target_link_libraries(MobileSharing PUBLIC ${CORE_LIBRARIES})
target_link_libraries(MobileSharing PRIVATE ${PLATFORM_LIBRARIES})

target_include_directories(MobileSharing PUBLIC ${CMAKE_CURRENT_LIST_DIR})

################################################################################

if (IOS)
    # Enable ARC for the Objective-C++ source
    set_target_properties(MobileSharing PROPERTIES XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES)
    target_compile_options(MobileSharing PRIVATE $<$<COMPILE_LANGUAGE:OBJCXX>:-fobjc-arc>)
endif()

################################################################################

# On Android the module owns its Java sources and FileProvider resources.
# We copy these files into QT_ANDROID_PACKAGE_SOURCE_DIR at configure time.
# We do not overwrite the filepaths.xml, because the parent application is free to use its own.
if (ANDROID)
    # If by any chance QT_ANDROID_PACKAGE_SOURCE_DIR exists as a variable (?) we use it
    if (NOT DEFINED MOBILESHARING_ANDROID_PACKAGE_SOURCE_DIR AND DEFINED QT_ANDROID_PACKAGE_SOURCE_DIR)
        set(MOBILESHARING_ANDROID_PACKAGE_SOURCE_DIR "${QT_ANDROID_PACKAGE_SOURCE_DIR}")
    endif()

    # If by any chance the directory "${CMAKE_SOURCE_DIR}/assets/android/" exists, we use it
    if (NOT DEFINED MOBILESHARING_ANDROID_PACKAGE_SOURCE_DIR AND EXISTS "${CMAKE_SOURCE_DIR}/assets/android")
        set(MOBILESHARING_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/assets/android")
    endif()

    if (DEFINED MOBILESHARING_ANDROID_PACKAGE_SOURCE_DIR)
        file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/android/src"
             DESTINATION "${MOBILESHARING_ANDROID_PACKAGE_SOURCE_DIR}")

        if (NOT EXISTS "${MOBILESHARING_ANDROID_PACKAGE_SOURCE_DIR}/res/xml/filepaths.xml")
            file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/android/res"
                 DESTINATION "${MOBILESHARING_ANDROID_PACKAGE_SOURCE_DIR}")
        endif()

        message(STATUS "MobileSharing > Deployed Android Java/res into ${MOBILESHARING_ANDROID_PACKAGE_SOURCE_DIR}")

        # Build-time re-deploy, to iterate on the module's Java/res WITHOUT a CMake
        # reconfigure (the file(COPY) above only runs at configure time). Invoke on
        # demand with:  cmake --build <dir> --target MobileSharing_deploy_android
        # In Debug builds it is also added to ALL, so it re-copies on every build.
        set(_mobilesharing_deploy_all "")
        if (CMAKE_BUILD_TYPE STREQUAL "Debug")
            set(_mobilesharing_deploy_all ALL)
        endif()
        add_custom_target(MobileSharing_deploy_android ${_mobilesharing_deploy_all}
            COMMAND ${CMAKE_COMMAND} -E copy_directory
                    "${CMAKE_CURRENT_SOURCE_DIR}/android/src"
                    "${MOBILESHARING_ANDROID_PACKAGE_SOURCE_DIR}/src"
            COMMAND ${CMAKE_COMMAND} -E copy_directory
                    "${CMAKE_CURRENT_SOURCE_DIR}/android/res"
                    "${MOBILESHARING_ANDROID_PACKAGE_SOURCE_DIR}/res"
            COMMENT "MobileSharing > Re-deploying Android Java/res (dev)"
            VERBATIM)
        unset(_mobilesharing_deploy_all)
    else()
        message(WARNING "MobileSharing > MOBILESHARING_ANDROID_PACKAGE_SOURCE_DIR is not set, "
                        "please provide the same path than your application's QT_ANDROID_PACKAGE_SOURCE_DIR before add_subdirectory(MobileSharing).")
    endif()
endif()

################################################################################
