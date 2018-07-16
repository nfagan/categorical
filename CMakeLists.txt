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
	add_executable(categorical-test "test/categorical.cpp")
	add_executable(bit_array-test "test/bit_array.cpp")

	target_link_libraries(categorical-test categorical)
	target_link_libraries(bit_array-test categorical)
else()
	#set(CMAKE_CXX_FLAGS "-Wall -fPIC -std=c++1y")
	#add_library(categorical SHARED ${SOURCES})
	set(CMAKE_CXX_FLAGS "-Wall -std=c++1y")
	add_library(categorical STATIC ${SOURCES})
endif()

install(TARGETS categorical DESTINATION ${CMAKE_SOURCE_DIR}/lib)