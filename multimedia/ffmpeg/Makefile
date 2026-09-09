#
# Copyright (C) 2017-2020 Ian Leonard <antonlacon@gmail.com>
# Copyright (C) 2018 Ted Hess <thess@kitschensync.net>
# Copyright (C) 2026 Mirko Vogt <mirko-openwrt@nanl.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Packaging principles:
#
#  * every build option is set explicitly - the build result only depends
#    on this package's own config symbols, never on which other packages
#    happen to be selected in the buildroot (--disable-autodetect plus an
#    explicit --enable-*/--disable-* for everything configure would
#    otherwise detect in the environment)
#  * each optional external library is one config symbol driving both the
#    conditional DEPENDS and the matching configure flag
#
# Two library variants: libffmpeg is the configurable one (menu below,
# defaults give a full-featured build), libffmpeg-mini a fixed small set of
# decoders for playback-only consumers. They conflict at install time.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ffmpeg
PKG_VERSION:=9.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://ffmpeg.org/releases/
PKG_HASH:=cf38e0e28c7e5605942c4a77755349b0145804a397af37eb1fb4c77cb237f635
PKG_MAINTAINER:=Ian Leonard <antonlacon@gmail.com>, \
		Mirko Vogt <mirko-openwrt@nanl.de>, \
		Daniel Golle <daniel@makrotopia.org>

PKG_LICENSE:=LGPL-2.1-or-later GPL-2.0-or-later LGPL-3.0-or-later GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING.GPLv2 COPYING.GPLv3 COPYING.LGPLv2.1 COPYING.LGPLv3
PKG_CPE_ID:=cpe:/a:ffmpeg:ffmpeg

PKG_BUILD_PARALLEL:=1

FFMPEG_ENCODERS:= \
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

FFMPEG_DECODERS:= \
	aac \
	aac_latm \
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
	opus \
	pcm_s16be \
	pcm_s16le \
	png \
	vc1 \
	vorbis \
	wavpack \
	wmalossless \
	wmapro \
	wmav1 \
	wmav2 \
	zlib \

FFMPEG_MUXERS:= \
	ac3 \
	avi \
	h264 \
	hevc \
	mp3 \
	mp4 \
	mpeg1video \
	mpeg2video \
	mpegts \
	ogg \
	rtp \

FFMPEG_DEMUXERS:= \
	aac \
	ac3 \
	aiff \
	amr \
	ape \
	avi \
	flac \
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
	vc1 \
	wav \
	wv \

FFMPEG_PARSERS:= \
	aac \
	ac3 \
	flac \
	h264 \
	hevc \
	mpegaudio \
	mpeg4video \
	mpegvideo \
	opus \
	vc1 \

FFMPEG_PROTOCOLS:= \
	file http icecast pipe rtp tcp udp

FFMPEG_MINI_DECODERS:= \
	ac3 \
	flac \
	jpegls \
	mp2 \
	mp3 \
	mpeg1video \
	mpeg2video \
	mpeg4 \
	mpegvideo \
	opus \
	png \
	vorbis \

FFMPEG_PATENTED_MINI_DECODERS:= \
	h264 \
	hevc \
	vc1 \

FFMPEG_MINI_DEMUXERS:= \
	avi \
	flac \
	matroska \
	mov \
	mp3 \
	mpegps \
	mpegts \
	mpegvideo \
	ogg \

FFMPEG_MINI_PROTOCOLS:= \
	file

FFMPEG_PATENTED_DECODERS:= \
	h264 \
	hevc \
	vc1 \
	vvc \

FFMPEG_PATENTED_MUXERS:= \
	h264 \
	hevc \
	vc1 \
	vvc \

FFMPEG_PATENTED_DEMUXERS:=$(FFMPEG_PATENTED_MUXERS)

FFMPEG_PATENTED_PARSERS:= \
	h264 \
	hevc \
	vc1 \
	vvc \

# everything that changes the build must be listed here, else a changed
# option does not trigger a rebuild
PKG_CONFIG_DEPENDS:= \
	CONFIG_BUILD_PATENTED \
	CONFIG_FFMPEG_X86ASM \
	CONFIG_FFMPEG_GPL \
	CONFIG_FFMPEG_VERSION3 \
	CONFIG_FFMPEG_NONFREE \
	CONFIG_FFMPEG_OPTIMIZE_SIZE \
	CONFIG_FFMPEG_PROGRAMS \
	CONFIG_FFMPEG_LIBDRM \
	CONFIG_FFMPEG_V4L2_M2M \
	CONFIG_FFMPEG_V4L2_REQUEST \
	CONFIG_FFMPEG_VAAPI \
	CONFIG_FFMPEG_LIBV4L2 \
	CONFIG_FFMPEG_TLS_NONE \
	CONFIG_FFMPEG_TLS_GNUTLS \
	CONFIG_FFMPEG_TLS_OPENSSL \
	CONFIG_FFMPEG_TLS_MBEDTLS \
	CONFIG_FFMPEG_BZLIB \
	CONFIG_FFMPEG_LZMA \
	CONFIG_FFMPEG_ICONV \
	CONFIG_FFMPEG_LIBDAV1D \
	CONFIG_FFMPEG_LIBOPUS \
	CONFIG_FFMPEG_LIBVORBIS \
	CONFIG_FFMPEG_LIBVPX \
	CONFIG_FFMPEG_LIBWEBP \
	CONFIG_FFMPEG_LIBSPEEX \
	CONFIG_FFMPEG_LIBXML2 \
	CONFIG_FFMPEG_LAME \
	CONFIG_FFMPEG_SHINE \
	CONFIG_FFMPEG_LIBX264 \
	CONFIG_FFMPEG_FDK_AAC \
	CONFIG_FFMPEG_SELECT_COMPONENTS \
	CONFIG_FFMPEG_DECODER_adpcm \
	$(patsubst %,CONFIG_FFMPEG_ENCODER_%,$(FFMPEG_ENCODERS)) \
	$(patsubst %,CONFIG_FFMPEG_DECODER_%,$(FFMPEG_DECODERS)) \
	$(patsubst %,CONFIG_FFMPEG_MUXER_%,$(FFMPEG_MUXERS)) \
	$(patsubst %,CONFIG_FFMPEG_DEMUXER_%,$(FFMPEG_DEMUXERS)) \
	$(patsubst %,CONFIG_FFMPEG_PARSER_%,$(FFMPEG_PARSERS)) \
	$(patsubst %,CONFIG_FFMPEG_PROTOCOL_%,$(FFMPEG_PROTOCOLS))

include $(INCLUDE_DIR)/package.mk

define Package/ffmpeg/Default
  TITLE:=FFmpeg
  URL:=https://ffmpeg.org/
  DEPENDS+= +libatomic
endef

define Package/ffmpeg/Default/description
  FFmpeg is a a software package that can record, convert and stream digital
  audio and video in numerous formats.

  FFmpeg licensing / patent issues are complex. It is the responsibility of the
  user to understand any requirements in this regard with its usage. See:
  https://ffmpeg.org/legal.html for further information.

  Patented codecs and technologies are available when CONFIG_BUILD_PATENTED=y.
endef


define Package/ffmpeg
$(call Package/ffmpeg/Default)
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE+= program
  DEPENDS+= @FFMPEG_PROGRAMS +libffmpeg
  VARIANT:=default
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
  DEPENDS+= @FFMPEG_PROGRAMS +libffmpeg
  VARIANT:=default
endef

define Package/ffprobe/description
$(call Package/ffmpeg/Default/description)
  .
  This package contains the FFprobe command line tool.
endef

define Package/libffmpeg/Default
$(call Package/ffmpeg/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= libraries
  DEPENDS+= +libpthread +zlib
endef

define Package/libffmpeg
$(call Package/libffmpeg/Default)
  DEPENDS+= \
	+FFMPEG_BZLIB:libbz2 \
	+FFMPEG_LZMA:liblzma \
	+FFMPEG_LIBDRM:libdrm \
	+FFMPEG_V4L2_REQUEST:libdrm \
	+FFMPEG_V4L2_REQUEST:libudev \
	+FFMPEG_LIBV4L2:libv4l \
	+FFMPEG_TLS_GNUTLS:libgnutls \
	+FFMPEG_TLS_OPENSSL:libopenssl \
	+FFMPEG_TLS_MBEDTLS:libmbedtls \
	+FFMPEG_LIBOPUS:libopus \
	+FFMPEG_LIBVORBIS:libvorbis \
	+FFMPEG_LIBVPX:libvpx \
	+FFMPEG_LIBWEBP:libwebp \
	+FFMPEG_LIBSPEEX:libspeex \
	+FFMPEG_LIBXML2:libxml2 \
	+FFMPEG_LAME:lame-lib \
	+FFMPEG_SHINE:shine \
	+FFMPEG_LIBX264:libx264 \
	+FFMPEG_FDK_AAC:fdk-aac
  # prepared, disabled until the libva / dav1d packages exist in the feeds
  # (the matching options in Config.in are commented out as well):
  #	+FFMPEG_VAAPI:libva
  #	+FFMPEG_LIBDAV1D:libdav1d
  VARIANT:=default
  # transitional aliases for packages still depending on the now gone ones
  PROVIDES:=libffmpeg-full libffmpeg-audio-dec
endef

# The menu is not guarded by PACKAGE_libffmpeg: its options pull their
# libraries themselves, and such a guard closes a Kconfig recursion as soon
# as a pulled library carries an @-dependency (e.g. libx264 on @BUILD_PATENTED).
define Package/libffmpeg/config
source "$(SOURCE)/Config.in"
endef

define Package/libffmpeg/description
$(call Package/ffmpeg/Default/description)
  .
  This package contains the FFmpeg shared libraries, built according to
  the "FFmpeg configuration" menu (full-featured by default).
endef

define Package/libffmpeg-mini
$(call Package/libffmpeg/Default)
  TITLE+= (mini)
  VARIANT:=mini
  CONFLICTS:=libffmpeg
endef

define Package/libffmpeg-mini/description
$(call Package/ffmpeg/Default/description)
  .
  This package contains a fixed, minimal set of FFmpeg shared libraries
  (a small set of decoders and demuxers, file protocol only). It is not
  configurable; use libffmpeg for anything beyond basic playback.
endef


# Strip off FPU notation
REAL_CPU_TYPE:=$(call qstrip,$(firstword $(subst +, ,$(CONFIG_CPU_TYPE))))
# Fixup cpu types recognized by ffmpeg configure
REAL_CPU_TYPE:=$(subst octeonplus,octeon+,$(REAL_CPU_TYPE))

# Base configuration, shared by all variants.
#
# --disable-autodetect makes the build deterministic: no library is used
# merely because it is present in the shared staging dir. Everything wanted
# is requested explicitly below; a requested but missing library is a
# configure error rather than a silently missing feature.
FFMPEG_CONFIGURE:= \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(FPIC)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	./configure \
	--enable-cross-compile \
	--cross-prefix="$(TARGET_CROSS)" \
	--arch="$(ARCH)" \
	$(if $(REAL_CPU_TYPE),--cpu=$(REAL_CPU_TYPE),) \
	--target-os=linux \
	--prefix="/usr" \
	--pkg-config="pkg-config" \
	--disable-autodetect \
	--enable-shared \
	--enable-static \
	--enable-pthreads \
	--enable-zlib \
	--disable-doc \
	--disable-debug \
	--disable-checkasm \
	--disable-vdpau \
	--disable-outdevs \
	\
	\
	--disable-alsa \
	--disable-sndio \
	--disable-sdl2 \
	--disable-xlib \
	--disable-libxcb \
	--disable-libxcb-shm \
	--disable-libxcb-shape \
	--disable-libxcb-xfixes \
	--disable-bzlib \
	--disable-iconv \
	--disable-lzma \
	\
	--disable-amf \
	--disable-vulkan \
	--disable-vaapi \
	--disable-libdrm \
	--disable-v4l2-m2m \
	--disable-v4l2-request \
	--disable-libudev
# Everything configure would autodetect on a Linux host is switched off
# explicitly above. --disable-autodetect already implies this; the explicit
# list documents the intent and is independent of changes to configure's
# autodetect list. The libffmpeg variant re-enables bzlib/iconv/lzma and the
# hwaccels through its FFMPEG_* options below; later flags take precedence.
# v4l2-request and libudev are introduced by patches/120-v4l2-request-*.patch,
# which also makes v4l2-request autodetected.

ifeq ($(CONFIG_SOFT_FLOAT),y)
FFMPEG_CONFIGURE+= \
	--disable-altivec \
	--disable-vsx \
	--disable-power8 \
	--disable-armv5te \
	--disable-armv6 \
	--disable-armv6t2 \
	--disable-fast-unaligned \
	--disable-runtime-cpudetect

else ifneq ($(findstring arm,$(CONFIG_ARCH))$(findstring aarch64,$(CONFIG_ARCH)),)
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

	ifneq ($(findstring vfp,$(CONFIG_CPU_TYPE)),)
		FFMPEG_CONFIGURE+= --enable-vfp
	else
		FFMPEG_CONFIGURE+= --disable-vfp
	endif
	ifneq ($(findstring neon,$(CONFIG_CPU_TYPE)),)
		FFMPEG_CONFIGURE+= \
			--enable-neon \
			--enable-vfp
	else
		FFMPEG_CONFIGURE+= --disable-neon
	endif
endif

ifneq ($(findstring aarch64,$(CONFIG_ARCH)),)
	FFMPEG_CONFIGURE+= \
		--enable-lto \
		--enable-neon \
		--enable-vfp
endif

ifeq ($(ARCH),x86_64)
	FFMPEG_CONFIGURE+= --enable-lto
endif

ifeq ($(CONFIG_FFMPEG_X86ASM),y)
  FFMPEG_CONFIGURE += --enable-x86asm
else
  FFMPEG_CONFIGURE += --disable-x86asm
endif

# helper: --enable-$(1)=$(c) for every entry of $(2) whose $(3)_$(c) symbol is set
FFMPEG_ENABLE_IF= \
	$(foreach c, $(2), \
		$(if $($(3)_$(c)),--enable-$(1)="$(c)") \
	)

# helper: --enable-$(1)=$(c) for every entry of $(2)
FFMPEG_ENABLE= \
	$(foreach c, $(2), \
		--enable-$(1)="$(c)" \
	)

# helper: --disable-$(1)=$(c) for every entry of $(2)
FFMPEG_DISABLE= \
	$(foreach c, $(2), \
		--disable-$(1)="$(c)" \
	)

# on/off helper for a config symbol
FFMPEG_OPT=$(if $(CONFIG_$(1)),--enable-$(2),--disable-$(2))

ifeq ($(BUILD_VARIANT),default)

  # postproc: libpostproc was removed upstream in FFmpeg 8.0 and is re-added
  # by patches/100-postproc.patch (LibreELEC), which also re-introduces the
  # --enable/--disable-postproc option; it is GPL-only, so it follows the GPL
  # option. Kodi requires it.
  # v4l2-request/libudev: options from patches/120-v4l2-request-*.patch, see
  # the common block above.
  # vaapi/libdav1d: literal --disable until the libva / dav1d packages exist
  # in the feeds; then restore $(call FFMPEG_OPT,FFMPEG_VAAPI,vaapi),
  # $(call FFMPEG_OPT,FFMPEG_LIBDAV1D,libdav1d) and, for manual component
  # selection, --enable-hwaccel=*_vaapi / --enable-decoder=libdav1d.
  FFMPEG_CONFIGURE+= \
	$(call FFMPEG_OPT,FFMPEG_GPL,gpl) \
	$(call FFMPEG_OPT,FFMPEG_GPL,postproc) \
	$(call FFMPEG_OPT,FFMPEG_VERSION3,version3) \
	$(call FFMPEG_OPT,FFMPEG_NONFREE,nonfree) \
	$(call FFMPEG_OPT,FFMPEG_OPTIMIZE_SIZE,small) \
	$(if $(CONFIG_FFMPEG_OPTIMIZE_SIZE),--disable-hardcoded-tables,--enable-hardcoded-tables) \
	$(call FFMPEG_OPT,FFMPEG_LIBDRM,libdrm) \
	$(call FFMPEG_OPT,FFMPEG_V4L2_M2M,v4l2-m2m) \
	$(call FFMPEG_OPT,FFMPEG_V4L2_REQUEST,v4l2-request) \
	$(call FFMPEG_OPT,FFMPEG_V4L2_REQUEST,libudev) \
	--disable-vaapi \
	$(call FFMPEG_OPT,FFMPEG_LIBV4L2,libv4l2) \
	$(call FFMPEG_OPT,FFMPEG_TLS_GNUTLS,gnutls) \
	$(call FFMPEG_OPT,FFMPEG_TLS_OPENSSL,openssl) \
	$(call FFMPEG_OPT,FFMPEG_TLS_MBEDTLS,mbedtls) \
	$(call FFMPEG_OPT,FFMPEG_BZLIB,bzlib) \
	$(call FFMPEG_OPT,FFMPEG_LZMA,lzma) \
	$(call FFMPEG_OPT,FFMPEG_ICONV,iconv) \
	--disable-libdav1d \
	$(call FFMPEG_OPT,FFMPEG_LIBOPUS,libopus) \
	$(call FFMPEG_OPT,FFMPEG_LIBVORBIS,libvorbis) \
	$(call FFMPEG_OPT,FFMPEG_LIBVPX,libvpx) \
	$(call FFMPEG_OPT,FFMPEG_LIBWEBP,libwebp) \
	$(call FFMPEG_OPT,FFMPEG_LIBSPEEX,libspeex) \
	$(call FFMPEG_OPT,FFMPEG_LIBXML2,libxml2) \
	$(call FFMPEG_OPT,FFMPEG_LAME,libmp3lame) \
	$(call FFMPEG_OPT,FFMPEG_SHINE,libshine) \
	$(call FFMPEG_OPT,FFMPEG_LIBX264,libx264) \
	$(call FFMPEG_OPT,FFMPEG_FDK_AAC,libfdk-aac)

  ifneq ($(CONFIG_FFMPEG_PROGRAMS),y)
	FFMPEG_CONFIGURE+= --disable-programs
  else
	FFMPEG_CONFIGURE+= \
		--enable-ffmpeg \
		--enable-ffprobe \
		--disable-ffplay
  endif

  # Component selection. By default every native component is built. With
  # manual selection the build starts from --disable-everything, enables the
  # selected components and adds those contributed by the selected external
  # libraries, hwaccels and TLS backend (configure's --enable-<class>=NAME
  # accepts shell globs; one flag per name, since commas would split make's
  # $(if) arguments).
  ifeq ($(CONFIG_FFMPEG_SELECT_COMPONENTS),y)
	FFMPEG_CONFIGURE+= \
		--disable-everything \
		$(call FFMPEG_ENABLE_IF,encoder,$(FFMPEG_ENCODERS),CONFIG_FFMPEG_ENCODER) \
		$(call FFMPEG_ENABLE_IF,decoder,$(FFMPEG_DECODERS),CONFIG_FFMPEG_DECODER) \
		$(call FFMPEG_ENABLE_IF,muxer,$(FFMPEG_MUXERS),CONFIG_FFMPEG_MUXER) \
		$(call FFMPEG_ENABLE_IF,demuxer,$(FFMPEG_DEMUXERS),CONFIG_FFMPEG_DEMUXER) \
		$(call FFMPEG_ENABLE_IF,parser,$(FFMPEG_PARSERS),CONFIG_FFMPEG_PARSER) \
		$(call FFMPEG_ENABLE_IF,protocol,$(FFMPEG_PROTOCOLS),CONFIG_FFMPEG_PROTOCOL) \
		$(if $(CONFIG_FFMPEG_DECODER_adpcm),--enable-decoder=adpcm_*) \
		$(if $(CONFIG_FFMPEG_TLS_NONE),,--enable-protocol=tls --enable-protocol=https) \
		$(if $(CONFIG_FFMPEG_V4L2_M2M),--enable-decoder=*_v4l2m2m --enable-encoder=*_v4l2m2m) \
		$(if $(CONFIG_FFMPEG_V4L2_REQUEST),--enable-hwaccel=*_v4l2request) \
		$(if $(CONFIG_FFMPEG_LIBOPUS),--enable-decoder=libopus --enable-encoder=libopus) \
		$(if $(CONFIG_FFMPEG_LIBVORBIS),--enable-encoder=libvorbis) \
		$(if $(CONFIG_FFMPEG_LIBVPX),--enable-decoder=libvpx_vp8 --enable-decoder=libvpx_vp9 --enable-encoder=libvpx_vp8 --enable-encoder=libvpx_vp9) \
		$(if $(CONFIG_FFMPEG_LIBWEBP),--enable-encoder=libwebp --enable-encoder=libwebp_anim) \
		$(if $(CONFIG_FFMPEG_LIBSPEEX),--enable-decoder=libspeex --enable-encoder=libspeex) \
		$(if $(CONFIG_FFMPEG_LIBXML2),--enable-demuxer=dash --enable-demuxer=imf) \
		$(if $(CONFIG_FFMPEG_LAME),--enable-encoder=libmp3lame) \
		$(if $(CONFIG_FFMPEG_SHINE),--enable-encoder=libshine) \
		$(if $(CONFIG_FFMPEG_LIBX264),--enable-encoder=libx264 --enable-encoder=libx264rgb) \
		$(if $(CONFIG_FFMPEG_FDK_AAC),--enable-decoder=libfdk_aac --enable-encoder=libfdk_aac)
  endif

  # patented components are never built without BUILD_PATENTED, regardless
  # of the component selection above (later flags take precedence)
  FFMPEG_CONFIGURE+= \
	$(if $(CONFIG_BUILD_PATENTED),, \
		$(call FFMPEG_DISABLE,decoder,$(FFMPEG_PATENTED_DECODERS)) \
		$(call FFMPEG_DISABLE,muxer,$(FFMPEG_PATENTED_MUXERS)) \
		$(call FFMPEG_DISABLE,demuxer,$(FFMPEG_PATENTED_DEMUXERS)) \
		$(call FFMPEG_DISABLE,parser,$(FFMPEG_PATENTED_PARSERS)))
endif

ifeq ($(BUILD_VARIANT),mini)

  FFMPEG_CONFIGURE+= \
	--enable-small \
	--disable-hardcoded-tables \
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
	$(call FFMPEG_ENABLE,protocol,$(FFMPEG_MINI_PROTOCOLS)) \
	$(if $(CONFIG_BUILD_PATENTED), \
		$(call FFMPEG_ENABLE,decoder,$(FFMPEG_PATENTED_MINI_DECODERS)))
endif

ifneq ($(CONFIG_TARGET_x86),)
  TARGET_CFLAGS+= -fomit-frame-pointer
endif

define Build/Configure
	( cd $(PKG_BUILD_DIR); $(FFMPEG_CONFIGURE) )
endef

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
endef

# stage whatever the variant built - headers, static and shared libraries,
# .pc files - so there is no per-variant library list to keep in sync
define Build/InstallDev/Default
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig/
endef

# Both variants stage into the same directory; libffmpeg takes precedence,
# mini is staged only when libffmpeg is not selected (the two conflict at
# install time).
ifeq ($(BUILD_VARIANT),default)
  Build/InstallDev = $(Build/InstallDev/Default)
endif
ifeq ($(BUILD_VARIANT),mini)
  ifeq ($(CONFIG_PACKAGE_libffmpeg),)
    Build/InstallDev = $(Build/InstallDev/Default)
  endif
endif

define Package/ffmpeg/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ffmpeg $(1)/usr/bin/ffmpeg
endef

define Package/ffprobe/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ffprobe $(1)/usr/bin/ffprobe
endef

# ship whatever shared libraries the variant built
define Package/libffmpeg/install/Default
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so.* $(1)/usr/lib/
endef

Package/libffmpeg/install = $(Package/libffmpeg/install/Default)
Package/libffmpeg-mini/install = $(Package/libffmpeg/install/Default)

$(eval $(call BuildPackage,ffmpeg))
$(eval $(call BuildPackage,ffprobe))
$(eval $(call BuildPackage,libffmpeg))
$(eval $(call BuildPackage,libffmpeg-mini))
