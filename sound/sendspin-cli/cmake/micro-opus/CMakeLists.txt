# Stands in for esphome-libs/micro-opus, which sendspin-cpp fetches to get a
# bundled copy of Opus. sendspin-cpp only links a target named micro_opus and
# includes <opus.h>, so the libopus from the OpenWrt feed is enough.
cmake_minimum_required(VERSION 3.16)
project(micro_opus LANGUAGES C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(OPUS REQUIRED IMPORTED_TARGET GLOBAL opus)

add_library(micro_opus INTERFACE)
target_link_libraries(micro_opus INTERFACE PkgConfig::OPUS)
