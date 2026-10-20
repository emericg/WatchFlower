cmake_minimum_required(VERSION 3.20)

project(MobileSharing LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_NO_PRIVATE_MODULE_WARNING ON)

################################################################################

set(ANDROID_DEPLOY_PATH "AUTO" CACHE STRING "Path to deploy Android resources into (AUTO / OFF / path)")

option(ANDROID_DEPLOY_SEND "Send/save files. Always on."                        ON)
option(ANDROID_DEPLOY_RECEIVE "Receive files."                                  ON)
option(ANDROID_DEPLOY_DOCUMENTPROVIDER "Android SAF DocumentsProvider support." ON)

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
    set(PLATFORM_SOURCES MobileSharing_android.cpp MobileSharing_android.h)

    if(Qt6Gui_VERSION VERSION_GREATER_EQUAL 6.10.0)
        find_package(Qt6 REQUIRED COMPONENTS CorePrivate)
        set(PLATFORM_LIBRARIES ${CORE_LIBRARIES} Qt6::CorePrivate)
    else()
        find_package(Qt6 REQUIRED COMPONENTS Core)
        set(PLATFORM_LIBRARIES ${CORE_LIBRARIES} Qt6::CorePrivate)
    endif()
elseif (IOS)
    enable_language(OBJCXX)
    set(PLATFORM_SOURCES MobileSharing_ios.mm)

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

if (ANDROID)
    # On Android the module owns its Java sources and FileProvider resources.
    # We copy these files into QT_ANDROID_PACKAGE_SOURCE_DIR at configure time.
    # We do not overwrite the filepaths.xml, because the parent application is free to use its own.

    if (ANDROID_DEPLOY_PATH AND NOT ANDROID_DEPLOY_PATH STREQUAL "OFF")

        if (ANDROID_DEPLOY_PATH STREQUAL "AUTO")
            # If by any chance QT_ANDROID_PACKAGE_SOURCE_DIR exists as a variable, or if
            # one of the following directories exists (platforms/android/, assets/android/, android/)
            if (DEFINED QT_ANDROID_PACKAGE_SOURCE_DIR)
                set(ANDROID_DEPLOY_PATH "${QT_ANDROID_PACKAGE_SOURCE_DIR}")
            elseif (EXISTS "${CMAKE_SOURCE_DIR}/platforms/android")
                set(ANDROID_DEPLOY_PATH "${CMAKE_SOURCE_DIR}/platforms/android")
            elseif (EXISTS "${CMAKE_SOURCE_DIR}/assets/android")
                set(ANDROID_DEPLOY_PATH "${CMAKE_SOURCE_DIR}/assets/android")
            elseif (EXISTS "${CMAKE_SOURCE_DIR}/android")
                set(ANDROID_DEPLOY_PATH "${CMAKE_SOURCE_DIR}/android")
            else()
                message(WARNING "MobileSharing > ANDROID_DEPLOY_PATH is not set!")
            endif()
        endif()

        if (EXISTS "${ANDROID_DEPLOY_PATH}")
            # Select which Java/res resources to deploy, per enabled feature:
            # - QShareUtils.java (Sending/viewing/saving files + outgoing FileProvider)
            # - QShareActivity.java (Receiving files with incoming SEND/VIEW intents)
            # - QShareDocumentProvider.java (Sharing a directory with SAF DocumentsProvider)
            # - res/xml/filepaths.xml (always deployed, but never overwritten, the parent app is free to use its own)

            set(_mobilesharing_resources "src/io/emeric/mobilesharing/QShareUtils.java")
            if (ANDROID_DEPLOY_RECEIVE)
                list(APPEND _mobilesharing_resources "src/io/emeric/mobilesharing/QShareActivity.java")
            endif()
            if (ANDROID_DEPLOY_DOCUMENTPROVIDER)
                list(APPEND _mobilesharing_resources "src/io/emeric/mobilesharing/QShareDocumentProvider.java")
            endif()
            if (NOT EXISTS "${ANDROID_DEPLOY_PATH}/res/xml/filepaths.xml")
                list(APPEND _mobilesharing_resources "res/xml/filepaths.xml")
            endif()

            # Configure-time deploy: copy each selected resource, preserving its subpath
            foreach(_ms_res IN LISTS _mobilesharing_resources)
                get_filename_component(_ms_res_subdir "${_ms_res}" DIRECTORY)
                file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/android/${_ms_res}"
                     DESTINATION "${ANDROID_DEPLOY_PATH}/${_ms_res_subdir}")
            endforeach()

            message(STATUS "MobileSharing > Deployed Android resources into ${ANDROID_DEPLOY_PATH}: ${_mobilesharing_resources}")
            unset(_mobilesharing_resources)

        else()
            message(WARNING "MobileSharing > ANDROID_DEPLOY_PATH ${ANDROID_DEPLOY_PATH} does not exist!")
        endif()
    endif()
endif()

################################################################################
