cmake_minimum_required(VERSION 3.20)

project(SunAndMoon LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

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
    SunAndMoon.cpp
    SunRise/SunRise.cpp
    MoonRise/MoonRise.cpp
    MoonPhase/MoonPhase.cpp
    SunAndMoon.h
    SunRise/SunRise.h
    MoonRise/MoonRise.h
    MoonPhase/MoonPhase.h
)

################################################################################

add_library(SunAndMoon OBJECT ${CORE_SOURCES})
add_library(SunAndMoon::SunAndMoon ALIAS SunAndMoon)

target_link_libraries(SunAndMoon PRIVATE ${CORE_LIBRARIES})
target_include_directories(SunAndMoon PUBLIC ${CMAKE_CURRENT_LIST_DIR})
