cmake_minimum_required(VERSION 2.6)

PROJECT(nginx-util CXX)

INCLUDE(CheckFunctionExists)

FIND_PATH(ubus_include_dir libubus.h)
FIND_LIBRARY(ubox NAMES ubox)
FIND_LIBRARY(ubus NAMES ubus)
INCLUDE_DIRECTORIES(${ubus_include_dir})

ADD_DEFINITIONS(-Os -Wall -Werror -Wextra --std=c++2a -g3)
ADD_DEFINITIONS(-Wno-unused-parameter -Wmissing-declarations)

SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")

ADD_EXECUTABLE(px5g px5g.cpp)
TARGET_LINK_LIBRARIES(px5g ssl crypto)

ADD_EXECUTABLE(nginx-util nginx-util.cpp)
TARGET_LINK_LIBRARIES(nginx-util ${ubox} ${ubus} pthread)

ADD_EXECUTABLE(nginx-ssl-util nginx-ssl-util.cpp)
TARGET_LINK_LIBRARIES(nginx-ssl-util ${ubox} ${ubus} pthread ssl crypto pcre)

ADD_EXECUTABLE(nginx-ssl-util-nopcre nginx-ssl-util.cpp)
TARGET_COMPILE_DEFINITIONS(nginx-ssl-util-nopcre PUBLIC -DNO_PCRE)
TARGET_LINK_LIBRARIES(nginx-ssl-util-nopcre ${ubox} ${ubus} pthread ssl crypto)

ADD_EXECUTABLE(nginx-ssl-util-noubus nginx-ssl-util.cpp)
TARGET_COMPILE_DEFINITIONS(nginx-ssl-util-noubus PUBLIC -DNO_UBUS)
TARGET_LINK_LIBRARIES(nginx-ssl-util-noubus pthread ssl crypto pcre)

INSTALL(TARGETS px5g RUNTIME DESTINATION bin)
INSTALL(TARGETS nginx-util RUNTIME DESTINATION bin)
INSTALL(TARGETS nginx-ssl-util RUNTIME DESTINATION bin)
INSTALL(TARGETS nginx-ssl-util-nopcre RUNTIME DESTINATION bin)
# INSTALL(TARGETS nginx-ssl-util-noubus RUNTIME DESTINATION bin)
