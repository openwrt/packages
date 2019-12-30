cmake_minimum_required(VERSION 2.8)

project(omxplayer)

add_definitions(-D__STDC_CONSTANT_MACROS)
add_definitions(-D__STDC_LIMIT_MACROS)
add_definitions(-DTARGET_POSIX)
add_definitions(-DTARGET_LINUX)
add_definitions(-D_REENTRANT)
add_definitions(-D_LARGEFILE64_SOURCE)
add_definitions(-D_FILE_OFFSET_BITS=64)
add_definitions(-DHAVE_CMAKE_CONFIG)
add_definitions(-D__VIDEOCORE4__)
add_definitions(-DHAVE_OMXLIB)
add_definitions(-DUSE_EXTERNAL_FFMPEG)
add_definitions(-DHAVE_LIBAVCODEC_AVCODEC_H)
add_definitions(-DHAVE_LIBAVUTIL_OPT_H)
add_definitions(-DHAVE_LIBAVUTIL_MEM_H)
add_definitions(-DHAVE_LIBAVUTIL_AVUTIL_H)
add_definitions(-DHAVE_LIBAVFORMAT_AVFORMAT_H)
add_definitions(-DHAVE_LIBAVFILTER_AVFILTER_H)
add_definitions(-DHAVE_LIBSWRESAMPLE_SWRESAMPLE_H)
add_definitions(-DOMX)
add_definitions(-DOMX_SKIP64BIT)
add_definitions(-DUSE_EXTERNAL_OMX)
add_definitions(-DTARGET_RASPBERRY_PI)
add_definitions(-DUSE_EXTERNAL_LIBBCM_HOST)

include_directories(.)
include_directories(linux)
include_directories(utils)

add_custom_command(OUTPUT help.h
	COMMAND awk
	ARGS '/SYNOPSIS/{p=1\;print\;next} p&&/KEY BINDINGS/{p=0}\;p' README.md | sed -e '1,3 d' -e 's/^/\"/' -e 's/$$/\\\\n\"/' > help.h
	DEPENDS README.md)

add_custom_command(OUTPUT keys.h
	COMMAND awk
	ARGS '/KEY BINDINGS/{p=1\;print\;next} p&&/KEY CONFIG/{p=0}\;p' README.md | sed -e '1,3 d' -e 's/^/\"/' -e 's/$$/\\\\n\"/' > keys.h
	DEPENDS README.md)

add_custom_command(OUTPUT version.h
	COMMAND gen_version.sh
	ARGS > keys.h)

set_property(SOURCE omxplayer.cpp APPEND PROPERTY OBJECT_DEPENDS help.h keys.h version.h)

add_executable(omxplayer.bin
	linux/XMemUtils.cpp
	linux/OMXAlsa.cpp
	utils/log.cpp
	DynamicDll.cpp
	utils/PCMRemap.cpp
	utils/RegExp.cpp
	OMXSubtitleTagSami.cpp
	OMXOverlayCodecText.cpp
	BitstreamConverter.cpp
	linux/RBP.cpp
	OMXThread.cpp
	OMXReader.cpp
	OMXStreamInfo.cpp
	OMXAudioCodecOMX.cpp
	OMXCore.cpp
	OMXVideo.cpp
	OMXAudio.cpp
	OMXClock.cpp
	File.cpp
	OMXPlayerVideo.cpp
	OMXPlayerAudio.cpp
	OMXPlayerSubtitles.cpp
	SubtitleRenderer.cpp
	Unicode.cpp
	Srt.cpp
	KeyConfig.cpp
	OMXControl.cpp
	Keyboard.cpp
	omxplayer.cpp
	revision.cpp)

target_link_libraries(omxplayer.bin
	brcmGLESv2
	brcmEGL
	bcm_host
	openmaxil
	freetype
	asound
	vchiq_arm
	vchostif
	vcos
	dbus-1
	pcre
	avcodec
	avformat
	avutil
	swresample
	swscale)

install(TARGETS omxplayer.bin
	RUNTIME DESTINATION bin)
