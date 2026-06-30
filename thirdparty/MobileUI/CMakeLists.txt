cmake_minimum_required(VERSION 3.20)

project(MobileUI LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

################################################################################

# Generic sources
set(CORE_SOURCES
    MobileUI.cpp MobileUI.h MobileUI_private.h
    MobileUI_QmlDispatcher.cpp MobileUI_QmlDispatcher.h )

# OS specific sources & dependencies
if(ANDROID)
    set(PLATFORM_SOURCES MobileUI_android.cpp)
elseif(IOS)
    enable_language(OBJCXX)
    set(PLATFORM_SOURCES MobileUI_ios.mm)
    set(PLATFORM_LIBRARIES "-framework UIKit" "-framework AVFoundation")
else()
    set(PLATFORM_SOURCES MobileUI_dummy.cpp)
endif()

################################################################################

find_package(Qt6 6.8 REQUIRED COMPONENTS Core Quick Qml)

qt_add_library(MobileUI STATIC)

qt_add_qml_module(MobileUI
    URI MobileUI
    VERSION 1.0
    DEPENDENCIES QtQuick
    PLUGIN_TARGET MobileUI_plugin
    SOURCES ${CORE_SOURCES} ${PLATFORM_SOURCES}
    #OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml/MobileUI"
)

target_link_libraries(MobileUI PUBLIC Qt6::Core Qt6::Quick Qt6::Qml)
target_link_libraries(MobileUI PRIVATE ${PLATFORM_LIBRARIES})

target_include_directories(MobileUI PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

################################################################################

if (IOS)
    # Enable ARC for the Objective-C++ source
    set_target_properties(MobileUI PROPERTIES XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES)
    target_compile_options(MobileUI PRIVATE $<$<COMPILE_LANGUAGE:OBJCXX>:-fobjc-arc>)
endif()

################################################################################
