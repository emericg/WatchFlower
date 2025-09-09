cmake_minimum_required(VERSION 3.20)

project(MobileSharing LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

################################################################################

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
    set(PLATFORM_LIBRARIES Qt::CorePrivate)
    set(PLATFORM_SOURCES
        SharingUtils_android.cpp
        SharingUtils_android.h)
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
