cmake_minimum_required(VERSION 3.0)

project(oui C)

find_package(Lua51 REQUIRED)

add_compile_options(-Os -std=gnu99 -g3 -Wall -Werror)

include_directories(${LUA_INCLUDE_DIR})

add_library(fs MODULE fs.c)
set_target_properties(fs PROPERTIES OUTPUT_NAME fs PREFIX "")

add_library(network MODULE network.c)
set_target_properties(network PROPERTIES OUTPUT_NAME network PREFIX "")

add_library(md5 MODULE md5.c)
set_target_properties(md5 PROPERTIES OUTPUT_NAME md5 PREFIX "")

install(
	TARGETS fs network
	DESTINATION lib/lua/oui/internal
)

install(
	TARGETS md5
	DESTINATION lib/lua/oui
)
