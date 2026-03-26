cmake_minimum_required(VERSION 3.20)

project(RC4 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

add_library(MobileUI OBJECT RC4.h RC4.cpp)
add_library(MobileUI::MobileUI ALIAS MobileUI)

target_link_libraries(MobileUI PRIVATE)
target_include_directories(MobileUI PUBLIC ${CMAKE_CURRENT_LIST_DIR})
