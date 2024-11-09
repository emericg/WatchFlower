project(SunAndMoon LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

################################################################################

# Generic dependencies
set(CORE_COMPONENTS Core Gui Qml)
find_package(Qt6 REQUIRED COMPONENTS ${CORE_COMPONENTS})


set(CORE_LIBRARIES Qt::Core)

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

target_compile_definitions(SunAndMoon PRIVATE _USE_MATH_DEFINES)
target_link_libraries(SunAndMoon PRIVATE ${CORE_LIBRARIES})
target_include_directories(SunAndMoon PUBLIC ${CMAKE_CURRENT_LIST_DIR})
