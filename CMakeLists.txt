cmake_minimum_required(VERSION 2.8)
project(categorical)

set(CMAKE_BINARY_DIR ${CMAKE_SOURCE_DIR}/build)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR})

include_directories(${CMAKE_SOURCE_DIR}/include/)
include_directories(${CMAKE_SOURCE_DIR}/src/)

file(GLOB SOURCES "src/*.c" "src/*.cpp" "src/*.hpp" "src/*.h")

if (APPLE OR WIN32)
	set(CMAKE_CXX_STANDARD 14)

	add_library(categorical STATIC ${SOURCES})
	add_executable(bit_array-test "test/bit_array.cpp")

	target_link_libraries(bit_array-test categorical)
else()
	set(CMAKE_CXX_STANDARD 14)
	set(CMAKE_CXX_FLAGS "-Wall -Wextra -Wpedantic -fPIC")

	add_library(categorical SHARED ${SOURCES})
endif()

add_executable(categorical-test "test/categorical.cpp")
target_link_libraries(categorical-test categorical)

if (APPLE)
	set(OUTPUT_LIB_SUBDIR mac)
elseif (WIN32)
	set(OUTPUT_LIB_SUBDIR win)
else()
	set(OUTPUT_LIB_SUBDIR linux)
endif()

install(TARGETS categorical DESTINATION ${CMAKE_SOURCE_DIR}/lib/${OUTPUT_LIB_SUBDIR})