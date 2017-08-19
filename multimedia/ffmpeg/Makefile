#
# Copyright (C) 2006-2017 OpenWrt.org
# Copyright (C) 2017 Ian Leonard <antonlacon@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ffmpeg
PKG_VERSION:=3.2.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://ffmpeg.org/releases/
PKG_HASH:=28e75fc32485a88035a7ebf0a956a1e5c7e93b440dd4bbd6bc30c7268cf34fe9
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>, \
		Ian Leonard <antonlacon@gmail.com>

PKG_LICENSE:=LGPL-2.1+ GPL-2+ LGPL-3
PKG_LICENSE_FILES:=COPYING.GPLv2 COPYING.GPLv3 COPYING.LGPLv2.1 COPYING.LGPLv3

FFMPEG_CUSTOM_ENCODERS:= \
	ac3 \
	jpegls \
	mpeg1video \
	mpeg2video \
	mpeg4 \
	pcm_s16be \
	pcm_s16le \
	png \
	vorbis \
	zlib \

FFMPEG_CUSTOM_DECODERS:= \
	aac \
	ac3 \
	alac \
	amrnb \
	amrwb \
	ape \
	atrac3 \
	flac \
	gif \
	h264 \
	hevc \
	jpegls \
	mp2 \
	mp3 \
	mpeg1video \
	mpeg2video \
	mpeg4 \
	mpegvideo \
	mpc7 \
	mpc8 \
	pcm_s16be \
	pcm_s16le \
	png \
	vc1 \
	vorbis \
	wavpack \
	wmav1 \
	wmav2 \
	zlib \

FFMPEG_CUSTOM_MUXERS:= \
	ac3 \
	ffm \
	h264 \
	hevc \
	mp3 \
	mp4 \
	mpeg1video \
	mpeg2video \
	mpegts \
	ogg \
	rtp \

FFMPEG_CUSTOM_DEMUXERS:= \
	aac \
	ac3 \
	amr \
	ape \
	avi \
	flac \
	ffm \
	h264 \
	hevc \
	matroska \
	mov \
	mp3 \
	mpegps \
	mpegts \
	mpegvideo \
	mpc \
	mpc8 \
	ogg \
	rm \
	rtsp \
	rtp \
	sdp \
	v4l2 \
	vc1 \
	wav \
	wv \

FFMPEG_CUSTOM_PARSERS:= \
	aac \
	flac \
	ac3 \
	h264 \
	hevc \
	mpegaudio \
	mpeg4video \
	mpegvideo \
	vc1 \

FFMPEG_CUSTOM_PROTOCOLS:= \
	file http icecast pipe rtp tcp udp

FFMPEG_MINI_DECODERS:= \
	aac \
	ac3 \
	flac \
	h264 \
	hevc \
	jpegls \
	mp3 \
	mpeg1video \
	mpeg2video \
	mpeg4 \
	mpegvideo \
	opus \
	png \
	vc1 \
	vorbis \
	wmav1 \
	wmav2 \

FFMPEG_MINI_DEMUXERS:= \
	avi \
	flac \
	matroska \
	mov \
	mp3 \
	mpegts \
	mpegvideo \
	ogg \

FFMPEG_MINI_PROTOCOLS:= \
	file

FFMPEG_AUDIO_DECODERS:= \
	aac \
	aac_latm \
	ac3 \
	adpcm_* \
	alac \
	amrnb \
	amrwb \
	ape \
	atrac3 \
	flac \
	mp2 \
	mp3* \
	mpc7 \
	mpc8 \
	opus \
	pcm_* \
	vorbis \
	wavpack \
	wmav1 \
	wmav2 \
	wmalossless \
	wmapro \
	zlib \

FFMPEG_AUDIO_DEMUXERS:= \
	aac \
	ac3 \
	aiff \
	amr \
	ape \
	avi \
	flac \
	ffm \
	matroska \
	mp3 \
	mov \
	mpc \
	mpc8 \
	mpegts \
	ogg \
	rm \
	rtsp \
	rtp \
	sdp \
	wav \
	wv \

FFMPEG_AUDIO_PROTOCOLS:= \
	file http icecast rtp tcp udp


PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_CONFIG_DEPENDS:= \
	$(patsubst %,CONFIG_FFMPEG_CUSTOM_ENCODER_%,$(FFMPEG_CUSTOM_ENCODERS)) \
	$(patsubst %,CONFIG_FFMPEG_CUSTOM_DECODER_%,$(FFMPEG_CUSTOM_DECODERS)) \
	$(patsubst %,CONFIG_FFMPEG_CUSTOM_MUXER_%,$(FFMPEG_CUSTOM_DEMUXERS)) \
	$(patsubst %,CONFIG_FFMPEG_CUSTOM_DEMUXER_%,$(FFMPEG_CUSTOM_DEMUXERS)) \
	$(patsubst %,CONFIG_FFMPEG_CUSTOM_PARSER_%,$(FFMPEG_CUSTOM_PARSERS)) \
	$(patsubst %,CONFIG_FFMPEG_CUSTOM_PROTOCOL_%,$(FFMPEG_CUSTOM_PROTOCOLS))

include $(INCLUDE_DIR)/package.mk

define Package/ffmpeg/Default
 TITLE:=FFmpeg
 URL:=https://ffmpeg.org/
 DEPENDS+= +libpthread
endef

define Package/ffmpeg/Default/description
 FFmpeg is a a software package that can record, convert and stream digital
 audio and video in numerous formats.
endef


define Package/ffmpeg
$(call Package/ffmpeg/Default)
 SECTION:=multimedia
 CATEGORY:=Multimedia
 TITLE+= program
 DEPENDS+= +libffmpeg-full
 VARIANT:=full
endef

define Package/ffmpeg/description
$(call Package/ffmpeg/Default/description)
 .
 This package contains the FFmpeg command line tool.
endef


define Package/ffprobe
$(call Package/ffmpeg/Default)
 SECTION:=multimedia
 CATEGORY:=Multimedia
 TITLE+= CLI media identifier
 DEPENDS+= +libffmpeg-full
 VARIANT:=full
endef

define Package/ffprobe/description
$(call Package/ffmpeg/Default/description)
 .
 This package contains the FFprobe command line tool.
endef


define Package/ffserver
$(call Package/ffserver/Default)
 SECTION:=multimedia
 CATEGORY:=Multimedia
 TITLE+= streaming server
 DEPENDS+= +libffmpeg-full
 VARIANT:=full
endef

define Package/ffserver/description
$(call Package/ffmpeg/Default/description)
 .
 This package contains the FFmpeg streaming server.
endef

define Package/libffmpeg/Default
$(call Package/ffmpeg/Default)
 SECTION:=libs
 CATEGORY:=Libraries
 TITLE+= libraries
 DEPENDS+= +libpthread +zlib +libbz2
 PROVIDES:= libffmpeg
endef


define Package/libffmpeg-custom
$(call Package/libffmpeg/Default)
 TITLE+= (custom)
 DEPENDS+= +FFMPEG_CUSTOM_SELECT_libopus:libopus \
           +PACKAGE_libx264:libx264 +PACKAGE_lame-lib:lame-lib \
           +FFMPEG_CUSTOM_SELECT_libshine:shine \
           +PACKAGE_fdk-aac:fdk-aac
 VARIANT:=custom
 MENU:=1
endef

define Package/libffmpeg-custom/config
source "$(SOURCE)/Config.in"
endef

define Package/libffmpeg-custom/description
$(call Package/ffmpeg/Default/description)
 .
 This package contains customized FFmpeg shared libraries.
endef


define Package/libffmpeg-audio-dec
$(call Package/libffmpeg/Default)
 TITLE+= (audio)
 DEPENDS+= @BUILD_PATENTED
 VARIANT:=audio-dec
endef

define Package/libffmpeg-audio-dec/description
$(call Package/ffmpeg/Default/description)
 .
 This package contains FFmpeg shared libraries for audio decoding
endef


define Package/libffmpeg-full
$(call Package/libffmpeg/Default)
 TITLE+= (full)
 DEPENDS+= @BUILD_PATENTED +alsa-lib +PACKAGE_libopus:libopus
 ifeq ($(CONFIG_SOFT_FLOAT),y)
	DEPENDS+= +PACKAGE_shine:shine
 else
	DEPENDS+= +PACKAGE_lame-lib:lame-lib +PACKAGE_libx264:libx264
 endif
 VARIANT:=full
endef


define Package/libffmpeg-full/description
$(call Package/ffmpeg/Default/description)
 .
 This package contains full-featured FFmpeg shared libraries.
endef


define Package/libffmpeg-mini
$(call Package/libffmpeg/Default)
 TITLE+= (mini)
 DEPENDS+= @BUILD_PATENTED
 VARIANT:=mini
endef

define Package/libffmpeg-mini/description
$(call Package/ffmpeg/Default/description)
 .
 This package contains minimal-featured FFmpeg shared libraries.
endef


FFMPEG_CONFIGURE:= \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(FPIC)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	./configure \
	--enable-cross-compile \
	--cross-prefix="$(TARGET_CROSS)" \
	--arch="$(ARCH)" \
	--target-os=linux \
	--prefix="/usr" \
	--pkg-config="pkg-config" \
	--enable-shared \
	--enable-static \
	--enable-pthreads \
	--enable-zlib \
	--disable-doc \
	--disable-debug \
	\
	--disable-lzma \
	--disable-vaapi \
	--disable-vdpau \
	--disable-outdevs

ifeq ($(CONFIG_SOFT_FLOAT),y)
FFMPEG_CONFIGURE+= \
	--disable-altivec \
	--disable-vsx \
	--disable-power8 \
	--disable-armv5te \
	--disable-armv6 \
	--disable-armv6t2 \
	--disable-inline-asm \
	--disable-mipsdsp \
	--disable-mipsdspr2 \
	--disable-mipsfpu \
	--disable-msa \
	--disable-mmi \
	--disable-fast-unaligned \
	--disable-runtime-cpudetect

else ifneq ($(findstring arm,$(CONFIG_ARCH)),)
FFMPEG_CONFIGURE+= \
	--disable-runtime-cpudetect
# XXX: GitHub issue 3320 ppc cpu with fpu but no altivec (WNDR4700)
else ifneq ($(findstring powerpc,$(CONFIG_ARCH)),)
FFMPEG_CONFIGURE+= \
	--disable-altivec
endif

# selectively disable optimizations according to arch/cpu type
ifneq ($(findstring arm,$(CONFIG_ARCH)),)
	FFMPEG_CONFIGURE+= --enable-lto

	ifneq ($(findstring vfp,$(CONFIG_TARGET_OPTIMIZATION)),)
		FFMPEG_CONFIGURE+= --enable-vfp
	else
		FFMPEG_CONFIGURE+= --disable-vfp
	endif
	ifneq ($(findstring neon,$(CONFIG_TARGET_OPTIMIZATION)),)
		FFMPEG_CONFIGURE+= \
			--enable-neon \
			--enable-vfp
	else
		FFMPEG_CONFIGURE+= --disable-neon
	endif

endif

ifeq ($(ARCH),x86_64)
	FFMPEG_CONFIGURE+= --enable-lto
endif

ifneq ($(CONFIG_YASM),y)
FFMPEG_CONFIGURE+= --disable-yasm

endif

ifeq ($(BUILD_VARIANT),full)
	FFMPEG_CONFIGURE+= \
		--enable-avresample \
		$(if $(CONFIG_PACKAGE_libopus),--enable-libopus)
  ifeq ($(CONFIG_SOFT_FLOAT),y)
	FFMPEG_CONFIGURE+= \
		--enable-small \
		\
		$(if $(CONFIG_PACKAGE_shine),--enable-libshine)
  else
	ifeq ($(ARCH),x86_64)
		FFMPEG_CONFIGURE+= --enable-hardcoded-tables
	else
		FFMPEG_CONFIGURE+= --enable-small
	endif
	FFMPEG_CONFIGURE+= \
		--enable-gpl \
		\
		$(if $(CONFIG_PACKAGE_lame-lib),--enable-libmp3lame) \
		$(if $(CONFIG_PACKAGE_libx264),--enable-libx264)
  endif
endif

ifeq ($(BUILD_VARIANT),custom)

  FFMPEG_ENABLE= \
	$(foreach c, $(2), \
		$(if $($(3)_$(c)),--enable-$(1)="$(c)") \
	)

  ifeq ($(CONFIG_FFMPEG_CUSTOM_LARGE),y)
	FFMPEG_CONFIGURE+= \
		--enable-hardcoded-tables
  else
	FFMPEG_CONFIGURE+= \
		--enable-small
  endif

  ifeq ($(CONFIG_FFMPEG_CUSTOM_GPL),y)
	FFMPEG_CONFIGURE+= --enable-gpl
  endif

  ifeq ($(CONFIG_FFMPEG_CUSTOM_GPLV3),y)
	FFMPEG_CONFIGURE+= --enable-version3
  endif

  ifeq ($(CONFIG_FFMPEG_CUSTOM_NONFREE),y)
	FFMPEG_CONFIGURE+= --enable-nonfree
  endif

  FFMPEG_CONFIGURE+= \
	--disable-programs \
	--disable-avfilter \
	--disable-postproc \
	--disable-swresample \
	--disable-swscale \
	--disable-everything \
	$(call FFMPEG_ENABLE,encoder,$(FFMPEG_CUSTOM_ENCODERS),CONFIG_FFMPEG_CUSTOM_ENCODER) \
	$(call FFMPEG_ENABLE,decoder,$(FFMPEG_CUSTOM_DECODERS),CONFIG_FFMPEG_CUSTOM_DECODER) \
	$(call FFMPEG_ENABLE,muxer,$(FFMPEG_CUSTOM_MUXERS),CONFIG_FFMPEG_CUSTOM_MUXER) \
	$(call FFMPEG_ENABLE,demuxer,$(FFMPEG_CUSTOM_DEMUXERS),CONFIG_FFMPEG_CUSTOM_DEMUXER) \
	$(call FFMPEG_ENABLE,parser,$(FFMPEG_CUSTOM_PARSERS),CONFIG_FFMPEG_CUSTOM_PARSER) \
	$(call FFMPEG_ENABLE,protocol,$(FFMPEG_CUSTOM_PROTOCOLS),CONFIG_FFMPEG_CUSTOM_PROTOCOL) \

ifeq ($(CONFIG_FFMPEG_CUSTOM_SELECT_adpcm),y)
  FFMPEG_CONFIGURE+= \
	--enable-decoder=adpcm_ima_wav \
	--enable-decoder=adpcm_ima_qt \
	--enable-decoder=adpcm_ms
endif

ifeq ($(CONFIG_FFMPEG_CUSTOM_SELECT_libfdk-aac),y)
  FFMPEG_CONFIGURE+= \
	--enable-libfdk-aac --enable-encoder=libfdk_aac
endif

ifeq ($(CONFIG_FFMPEG_CUSTOM_SELECT_libmp3lame),y)
  FFMPEG_CONFIGURE+= \
	--enable-libmp3lame --enable-encoder=libmp3lame
endif

ifeq ($(CONFIG_FFMPEG_CUSTOM_SELECT_libopus),y)
  FFMPEG_CONFIGURE+= \
	--enable-libopus --enable-decoder=libopus --enable-encoder=libopus
endif

ifeq ($(CONFIG_FFMPEG_CUSTOM_SELECT_libshine),y)
  FFMPEG_CONFIGURE+= \
	--enable-libshine --enable-encoder=libshine
endif

ifeq ($(CONFIG_FFMPEG_CUSTOM_SELECT_libx264),y)
  FFMPEG_CONFIGURE+= \
	--enable-libx264 --enable-encoder=libx264
endif

endif

ifeq ($(BUILD_VARIANT),audio-dec)

  FFMPEG_ENABLE= \
	$(foreach c, $(2), \
		--enable-$(1)="$(c)" \
	)

  FFMPEG_CONFIGURE+= \
	--enable-small \
	--enable-gpl \
	\
	--disable-programs \
	--disable-avfilter \
	--disable-postproc \
	--disable-swresample \
	--disable-swscale \
	--disable-everything \
	$(call FFMPEG_ENABLE,decoder,$(FFMPEG_AUDIO_DECODERS)) \
	$(call FFMPEG_ENABLE,demuxer,$(FFMPEG_AUDIO_DEMUXERS)) \
	$(call FFMPEG_ENABLE,protocol,$(FFMPEG_AUDIO_PROTOCOLS)) \
	--disable-decoder=pcm_bluray,pcm_dvd \

endif

ifeq ($(BUILD_VARIANT),mini)

  FFMPEG_ENABLE= \
	$(foreach c, $(2), \
		--enable-$(1)="$(c)" \
	)

  FFMPEG_CONFIGURE+= \
	--enable-small \
	\
	--disable-programs \
	--disable-avdevice \
	--disable-avfilter \
	--disable-postproc \
	--disable-swresample \
	--disable-swscale \
	--disable-everything \
	$(call FFMPEG_ENABLE,decoder,$(FFMPEG_MINI_DECODERS)) \
	$(call FFMPEG_ENABLE,demuxer,$(FFMPEG_MINI_DEMUXERS)) \
	$(call FFMPEG_ENABLE,protocol,$(FFMPEG_MINI_PROTOCOLS))
endif

ifneq ($(CONFIG_TARGET_x86),)
  TARGET_CFLAGS+= -fomit-frame-pointer
endif

define Build/Configure
	( cd $(PKG_BUILD_DIR); $(FFMPEG_CONFIGURE) )
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
endef

define Build/InstallDev/custom
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/lib{avcodec,avdevice,avformat,avutil} $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{avcodec,avdevice,avformat,avutil}.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/lib{avcodec,avdevice,avformat,avutil}.pc $(1)/usr/lib/pkgconfig/
endef

# Soft float is LGPL (no libpostproc); Hard float is GPL (yes libpostproc)
define Build/InstallDev/full
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/lib{avcodec,avdevice,avfilter,avformat,avresample,avutil,swresample,swscale} $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{avcodec,avdevice,avfilter,avformat,avresample,avutil,swresample,swscale}.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/lib{avcodec,avdevice,avfilter,avformat,avresample,avutil,swresample,swscale}.pc $(1)/usr/lib/pkgconfig/
ifneq ($(CONFIG_SOFT_FLOAT),y)
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libpostproc $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpostproc.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libpostproc.pc $(1)/usr/lib/pkgconfig/
endif
endef

define Build/InstallDev/mini
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/lib{avcodec,avformat,avutil} $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{avcodec,avformat,avutil}.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/lib{avcodec,avformat,avutil}.pc $(1)/usr/lib/pkgconfig/
endef

Build/InstallDev/audio-dec = $(Build/InstallDev/custom)

# XXX: attempt at installing "best" dev files available
ifeq ($(BUILD_VARIANT),custom)
  # XXX: only install "custom" dev files if -full & -mini are not selected
  ifeq ($(CONFIG_PACKAGE_libffmpeg-full)$(CONFIG_PACKAGE_libffmpeg-mini),)
    Build/InstallDev = $(Build/InstallDev/custom)
  endif
endif
ifeq ($(BUILD_VARIANT),audio-dec)
  # XXX: only install "audio-dec" dev files if -full & -mini are not selected
  ifeq ($(CONFIG_PACKAGE_libffmpeg-full)$(CONFIG_PACKAGE_libffmpeg-mini),)
    Build/InstallDev = $(Build/InstallDev/audio-dec)
  endif
endif
ifeq ($(BUILD_VARIANT),full)
  # XXX: always install "full" dev files if -full is selected
  Build/InstallDev = $(Build/InstallDev/full)
endif
ifeq ($(BUILD_VARIANT),mini)
  # XXX: only install "mini" dev files if -full is not selected
  ifeq ($(CONFIG_PACKAGE_libffmpeg-full),)
    Build/InstallDev = $(Build/InstallDev/mini)
  endif
endif

define Package/ffmpeg/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ffmpeg $(1)/usr/bin/
endef

define Package/ffprobe/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ffprobe $(1)/usr/bin/
endef

define Package/ffserver/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ffserver $(1)/usr/bin/
endef

define Package/libffmpeg-custom/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{avcodec,avdevice,avformat,avutil}.so.* $(1)/usr/lib/
endef

# Soft float is LGPL (no libpostproc); Hard float is GPL (yes libpostproc)
define Package/libffmpeg-full/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{avcodec,avdevice,avfilter,avformat,avresample,avutil,swresample,swscale}.so.* $(1)/usr/lib/
ifneq ($(CONFIG_SOFT_FLOAT),y)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpostproc.so.* $(1)/usr/lib/
endif
endef

define Package/libffmpeg-mini/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{avcodec,avformat,avutil}.so.* $(1)/usr/lib/
endef

Package/libffmpeg-audio-dec/install = $(Package/libffmpeg-custom/install)

$(eval $(call BuildPackage,ffmpeg))
$(eval $(call BuildPackage,ffprobe))
$(eval $(call BuildPackage,ffserver))
$(eval $(call BuildPackage,libffmpeg-audio-dec))
$(eval $(call BuildPackage,libffmpeg-full))
$(eval $(call BuildPackage,libffmpeg-mini))
ifneq ($(CONFIG_ALL),y)
   $(eval $(call BuildPackage,libffmpeg-custom))
endif
