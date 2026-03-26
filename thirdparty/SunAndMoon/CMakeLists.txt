cmake_minimum_required(VERSION 3.20)

project(SunAndMoon LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

################################################################################

# Generic dependencies
find_package(Qt6 REQUIRED COMPONENTS Core)
set(CORE_LIBRARIES Qt::Core)

# Generic sources
set(CORE_SOURCES
    SunAndMoon.cpp SunAndMoon.h
    SunRise/SunRise.cpp SunRise/SunRise.h
    MoonRise/MoonRise.cpp MoonRise/MoonRise.h
    MoonPhase/MoonPhase.cpp MoonPhase/MoonPhase.h
)

################################################################################

add_library(SunAndMoon OBJECT ${CORE_SOURCES})
add_library(SunAndMoon::SunAndMoon ALIAS SunAndMoon)

target_compile_definitions(SunAndMoon PRIVATE _USE_MATH_DEFINES)
target_link_libraries(SunAndMoon PRIVATE ${CORE_LIBRARIES})
target_include_directories(SunAndMoon PUBLIC ${CMAKE_CURRENT_LIST_DIR})
