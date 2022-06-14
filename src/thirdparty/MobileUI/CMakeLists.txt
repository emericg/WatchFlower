cmake_minimum_required(VERSION 3.12)

project(MobileUI LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_AUTOMOC ON)

################################################################################

if(NOT QT_DEFAULT_MAJOR_VERSION)
    set(QT_DEFAULT_MAJOR_VERSION 6 CACHE STRING "Qt version to use (5 or 6), defaults to 6")
endif()

# Generic dependencies
set(CORE_COMPONENTS Core Gui Qml)
find_package(Qt${QT_DEFAULT_MAJOR_VERSION} REQUIRED COMPONENTS ${CORE_COMPONENTS})

set(CORE_LIBRARIES
    Qt::Core
    Qt::Gui
    Qt::Qml)

# Generic sources
set(CORE_SOURCES
    MobileUI.h
    MobileUI.cpp)

# OS specific sources & dependencies
if (ANDROID)
    if(QT_DEFAULT_MAJOR_VERSION EQUAL 5)
        set(PLATFORM_SOURCES MobileUI_android_qt5.cpp)

        find_package(Qt${QT_DEFAULT_MAJOR_VERSION} REQUIRED COMPONENTS AndroidExtras)
        target_link_libraries(MobileUI PRIVATE Qt::AndroidExtras)
    elseif(QT_DEFAULT_MAJOR_VERSION EQUAL 6)
        set(PLATFORM_SOURCES MobileUI_android_qt6.cpp)
    endif()
elseif(IOS)
    set(PLATFORM_SOURCES MobileUI_ios.mm)
    set(PLATFORM_LIBRARIES "-framework UIKit")
else()
    set(PLATFORM_SOURCES MobileUI_dummy.cpp)
endif()

################################################################################

add_library(MobileUI OBJECT ${CORE_SOURCES} ${PLATFORM_SOURCES})
add_library(MobileUI::MobileUI ALIAS MobileUI)

target_link_libraries(MobileUI PRIVATE ${CORE_LIBRARIES} ${PLATFORM_LIBRARIES})
target_include_directories(MobileUI PUBLIC ${CMAKE_CURRENT_LIST_DIR})
