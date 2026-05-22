cmake_minimum_required(VERSION 3.20)

project(RC4 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(RC4 STATIC RC4.h RC4.cpp)
add_library(RC4::RC4 ALIAS RC4)

target_include_directories(RC4 PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
