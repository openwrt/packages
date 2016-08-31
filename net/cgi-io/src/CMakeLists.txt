cmake_minimum_required(VERSION 2.6)

PROJECT(cgi-io C)

INCLUDE(CheckFunctionExists)

ADD_DEFINITIONS(-Os -Wall -Werror --std=gnu99 -g3 -Wmissing-declarations)

SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")

IF(APPLE)
  INCLUDE_DIRECTORIES(/opt/local/include)
  LINK_DIRECTORIES(/opt/local/lib)
ENDIF()

ADD_EXECUTABLE(cgi-io main.c multipart_parser.c)
TARGET_LINK_LIBRARIES(cgi-io ubox ubus)

INSTALL(TARGETS cgi-io RUNTIME DESTINATION sbin)
