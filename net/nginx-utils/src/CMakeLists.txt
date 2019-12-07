cmake_minimum_required(VERSION 2.6)

PROJECT(nginx-utils CXX)

INCLUDE(CheckFunctionExists)

FIND_PATH(ubus_include_dir libubus.h)
FIND_LIBRARY(pcre NAMES pcre) #TODO
FIND_LIBRARY(ubox NAMES ubox)
FIND_LIBRARY(ubus NAMES ubus)
INCLUDE_DIRECTORIES(${ubus_include_dir})

ADD_DEFINITIONS(-Os -Wall -Werror -Wextra --std=c++17 -g3)
ADD_DEFINITIONS(-Wno-unused-parameter -Wmissing-declarations)

SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")

ADD_EXECUTABLE(nginx-ssl-util nginx-ssl-util.cpp)
TARGET_LINK_LIBRARIES(nginx-ssl-util ${pcre} ${ubox} ${ubus}) #TODO

INSTALL(TARGETS nginx-ssl-util RUNTIME DESTINATION bin)
