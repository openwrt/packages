cmake_minimum_required(VERSION 3.18.4)
project(basicstation)

add_compile_definitions(CFG_linux)
add_compile_definitions(CFG_lgw1)
add_compile_definitions(CFG_sx1302)
add_compile_definitions(CFG_ral_lgw)
add_compile_definitions(CFG_no_leds)
add_compile_definitions(CFG_argp)
add_compile_definitions(CFG_platform="linux")
add_compile_definitions(CFG_bdate=${PKG_SOURCE_DATE})
file(STRINGS "VERSION.txt" VERSION_NUMBER)
add_compile_definitions(CFG_version="${VERSION_NUMBER}")


include_directories(src)
include_directories(src-linux)

find_path(SX1302_HAL_INCLUDE_DIR NAMES lgw/loragw_hal.h)
find_path(MBEDTLS_INCLUDE_DIR NAMES mbedtls/x509.h)
find_library(SX1302_HAL_LIBRARY NAMES libloragw.a PATH /usr/lib/)
find_library(TINYMT32_LIBRARY NAMES libtinymt32.a PATH /usr/lib/)
find_library(MBEDTLS_LIBRARY NAMES libmbedtls.a PATH /usr/lib/)
find_library(MBEDCRYPTO_LIBRARY NAMES libmbedcrypto.a PATH /usr/lib/)
find_library(MBEDX509_LIBRARY NAMES libmbedx509.a PATH /usr/lib/)

set(basicstation_SOURCE_FILES
	src/aio.c
	src/argp.c
	src/crc32.c
	src/cups.c
	src/flashsim.c
	src/fs.c
	src/genkwcrcs.c
	src/lgwsim.c
	src/log.c
	src/lora.c
	src/net.c
	src/ral.c
	src/ral_lgw.c
	src/ral_lgw2.c
	src/rt.c
	src/s2conf.c
	src/s2e.c
	src/selftest_fs.c
	src/selftest_lora.c
	src/selftest_rt.c
	src/selftest_ujdec.c
	src/selftest_ujenc.c
	src/selftest_xprintf.c
	src/selftest_xq.c
	src/selftests.c
	src/sx1301v2conf.c
	src/sx130xconf.c
	src/sys.c
	src/sys.h
	src/tc.c
	src/timesync.c
	src/tls.c
	src/uj.c
	src/web.c
	src/xq.c
	src-linux/cmdfifo.c
	src-linux/commands.c
	src-linux/gps.c
	src-linux/leds.c
	src-linux/ral_master.c
	src-linux/ral_slave.c
	src-linux/rmtsh.c
	src-linux/sys_linux.c
	src-linux/sys_log.c
	src-linux/web_linux.c)

add_library(s2core ${basicstation_SOURCE_FILES})
target_include_directories(s2core PRIVATE ${SX1302_HAL_INCLUDE_DIR})
target_include_directories(s2core PRIVATE ${MBEDTLS_INCLUDE_DIR})
target_link_libraries(s2core ${SX1302_HAL_LIBRARY} ${TINYMT32_LIBRARY} m)
target_link_libraries(s2core ${MBEDTLS_LIBRARY})
target_link_libraries(s2core ${MBEDCRYPTO_LIBRARY})
target_link_libraries(s2core ${MBEDX509_LIBRARY})

add_executable(station src-linux/station_main.c)

target_link_libraries(station s2core)

install(TARGETS station RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
