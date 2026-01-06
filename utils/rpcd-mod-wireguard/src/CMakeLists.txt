cmake_minimum_required(VERSION 3.30)
PROJECT(rpcd-mod-wireguard)
ADD_DEFINITIONS(-Os -Wall -Werror --std=gnu99 -g3 -Wmissing-declarations)

SET(SOURCES wireguard.c api.c)

ADD_LIBRARY(rpcd-mod-wireguard SHARED ${SOURCES})

SET_TARGET_PROPERTIES(rpcd-mod-wireguard PROPERTIES OUTPUT_NAME wireguard PREFIX "")
INSTALL(TARGETS rpcd-mod-wireguard LIBRARY DESTINATION lib/rpcd)
