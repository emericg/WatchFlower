cmake_minimum_required(VERSION 3.20)

project(MobileSharing LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

################################################################################

if(NOT QT_DEFAULT_MAJOR_VERSION)
    set(QT_DEFAULT_MAJOR_VERSION 6 CACHE STRING "Qt version to use (5 or 6), defaults to 6")
endif()

# Generic dependencies
set(CORE_COMPONENTS Core Gui Qml)
find_package(Qt${QT_DEFAULT_MAJOR_VERSION} REQUIRED COMPONENTS ${CORE_COMPONENTS})

set(CORE_LIBRARIES Qt::Core Qt::Gui Qt::Qml)

# Generic sources
set(CORE_SOURCES
    SharingApplication.cpp SharingApplication.h
    SharingUtils.cpp SharingUtils.h)

# OS specific sources & dependencies
if (ANDROID)
    if(QT_DEFAULT_MAJOR_VERSION EQUAL 6)
        set(PLATFORM_SOURCES
            SharingUtils_android_qt6.cpp
            SharingUtils_android.h)

        set(PLATFORM_LIBRARIES Qt::CorePrivate)
    elseif(QT_DEFAULT_MAJOR_VERSION EQUAL 5)
        set(PLATFORM_SOURCES
            SharingUtils_android_qt5.cpp
            SharingUtils_android.h)

        find_package(Qt${QT_DEFAULT_MAJOR_VERSION} REQUIRED COMPONENTS AndroidExtras)
        set(PLATFORM_LIBRARIES Qt::AndroidExtras)
    endif()

elseif (IOS)
    find_package(Qt${QT_DEFAULT_MAJOR_VERSION} REQUIRED COMPONENTS Quick)
    set(PLATFORM_LIBRARIES Qt::Quick)
    set(PLATFORM_SOURCES
        SharingUtils_ios.mm
        docviewcontroller_ios.mm)
endif()

################################################################################

add_library(MobileSharing OBJECT ${CORE_SOURCES} ${PLATFORM_SOURCES})
add_library(MobileSharing::MobileSharing ALIAS MobileSharing)

target_link_libraries(MobileSharing PRIVATE ${CORE_LIBRARIES} ${PLATFORM_LIBRARIES})
target_include_directories(MobileSharing PUBLIC ${CMAKE_CURRENT_LIST_DIR})
