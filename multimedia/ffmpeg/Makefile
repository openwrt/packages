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
#    otherwise pick up from the environment)
#  * each optional external library is one config symbol driving both the
#    conditional DEPENDS and the matching configure flag
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ffmpeg
PKG_VERSION:=9.0.1
PKG_RELEASE:=1

PKG_SOURCE:=ffmpeg-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://ffmpeg.org/releases/
PKG_HASH:=cf38e0e28c7e5605942c4a77755349b0145804a397af37eb1fb4c77cb237f635
# the tarball unpacks into ffmpeg-$(PKG_VERSION), not $(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(if $(BUILD_VARIANT),$(PKG_NAME)-$(BUILD_VARIANT)/)ffmpeg-$(PKG_VERSION)

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>, \
		Ian Leonard <antonlacon@gmail.com>

PKG_LICENSE:=LGPL-2.1-or-later GPL-2.0-or-later LGPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING.GPLv2 COPYING.GPLv3 COPYING.LGPLv2.1 COPYING.LGPLv3
PKG_CPE_ID:=cpe:/a:ffmpeg:ffmpeg

PKG_BUILD_PARALLEL:=1

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
	avi \
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

FFMPEG_AUDIO_DECODERS:= \
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
	zlib \

FFMPEG_AUDIO_DEMUXERS:= \
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

FFMPEG_PATENTED_DECODERS:= \
	h264 \
	hevc \
	vc1 \

FFMPEG_PATENTED_MUXERS:= \
	h264 \
	hevc \
	vc1 \

FFMPEG_PATENTED_DEMUXERS:=$(FFMPEG_PATENTED_MUXERS)

FFMPEG_PATENTED_PARSERS:= \
	h264 \
	hevc \
	vc1 \

# everything that changes the build must be listed here, else a changed
# option does not trigger a rebuild
PKG_CONFIG_DEPENDS:= \
	CONFIG_BUILD_PATENTED \
	CONFIG_FFMPEG_X86ASM \
	CONFIG_FFMPEG_FULL_GPL \
	CONFIG_FFMPEG_FULL_VERSION3 \
	CONFIG_FFMPEG_FULL_NONFREE \
	CONFIG_FFMPEG_FULL_OPTIMIZE_SIZE \
	CONFIG_FFMPEG_FULL_PROGRAMS \
	CONFIG_FFMPEG_FULL_LIBDRM \
	CONFIG_FFMPEG_FULL_V4L2_M2M \
	CONFIG_FFMPEG_FULL_V4L2_REQUEST \
	CONFIG_FFMPEG_FULL_VAAPI \
	CONFIG_FFMPEG_FULL_LIBV4L2 \
	CONFIG_FFMPEG_FULL_TLS_NONE \
	CONFIG_FFMPEG_FULL_TLS_GNUTLS \
	CONFIG_FFMPEG_FULL_TLS_OPENSSL \
	CONFIG_FFMPEG_FULL_TLS_MBEDTLS \
	CONFIG_FFMPEG_FULL_BZLIB \
	CONFIG_FFMPEG_FULL_LZMA \
	CONFIG_FFMPEG_FULL_ICONV \
	CONFIG_FFMPEG_FULL_LIBDAV1D \
	CONFIG_FFMPEG_FULL_LIBOPUS \
	CONFIG_FFMPEG_FULL_LIBVORBIS \
	CONFIG_FFMPEG_FULL_LIBVPX \
	CONFIG_FFMPEG_FULL_LIBWEBP \
	CONFIG_FFMPEG_FULL_LIBSPEEX \
	CONFIG_FFMPEG_FULL_LIBXML2 \
	CONFIG_FFMPEG_FULL_LAME \
	CONFIG_FFMPEG_FULL_SHINE \
	CONFIG_FFMPEG_FULL_LIBX264 \
	CONFIG_FFMPEG_FULL_FDK_AAC \
	CONFIG_FFMPEG_CUSTOM_GPL \
	CONFIG_FFMPEG_CUSTOM_GPLV3 \
	CONFIG_FFMPEG_CUSTOM_NONFREE \
	CONFIG_FFMPEG_CUSTOM_LARGE \
	CONFIG_FFMPEG_CUSTOM_PROGRAMS \
	CONFIG_FFMPEG_CUSTOM_SELECT_adpcm \
	CONFIG_FFMPEG_CUSTOM_SELECT_libfdk-aac \
	CONFIG_FFMPEG_CUSTOM_SELECT_libmp3lame \
	CONFIG_FFMPEG_CUSTOM_SELECT_libopus \
	CONFIG_FFMPEG_CUSTOM_SELECT_libshine \
	CONFIG_FFMPEG_CUSTOM_SELECT_libx264 \
	$(patsubst %,CONFIG_FFMPEG_CUSTOM_ENCODER_%,$(FFMPEG_CUSTOM_ENCODERS)) \
	$(patsubst %,CONFIG_FFMPEG_CUSTOM_DECODER_%,$(FFMPEG_CUSTOM_DECODERS)) \
	$(patsubst %,CONFIG_FFMPEG_CUSTOM_MUXER_%,$(FFMPEG_CUSTOM_MUXERS)) \
	$(patsubst %,CONFIG_FFMPEG_CUSTOM_DEMUXER_%,$(FFMPEG_CUSTOM_DEMUXERS)) \
	$(patsubst %,CONFIG_FFMPEG_CUSTOM_PARSER_%,$(FFMPEG_CUSTOM_PARSERS)) \
	$(patsubst %,CONFIG_FFMPEG_CUSTOM_PROTOCOL_%,$(FFMPEG_CUSTOM_PROTOCOLS))

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
 DEPENDS+= +libffmpeg-full
 VARIANT:=full
endef

define Package/ffmpeg-custom
$(call Package/ffmpeg/Default)
 SECTION:=multimedia
 CATEGORY:=Multimedia
 TITLE+= program (custom)
 DEPENDS+= @!ALL libffmpeg-custom
 CONFLICTS:=ffmpeg
 VARIANT:=custom
endef

define Package/ffmpeg/description
$(call Package/ffmpeg/Default/description)
 .
 This package contains the FFmpeg command line tool.
endef

Package/ffmpeg-custom/description = $(Package/ffmpeg/description)

define Package/ffprobe
$(call Package/ffmpeg/Default)
 SECTION:=multimedia
 CATEGORY:=Multimedia
 TITLE+= CLI media identifier
 DEPENDS+= +libffmpeg-full
 VARIANT:=full
endef

define Package/ffprobe-custom
$(call Package/ffmpeg/Default)
 SECTION:=multimedia
 CATEGORY:=Multimedia
 TITLE+= CLI media identifier (custom)
 DEPENDS+= @!ALL libffmpeg-custom
 CONFLICTS:=ffprobe
 VARIANT:=custom
endef

define Package/ffprobe/description
$(call Package/ffmpeg/Default/description)
 .
 This package contains the FFprobe command line tool.
endef

Package/ffprobe-custom/description = $(Package/ffprobe/description)

define Package/libffmpeg/Default
$(call Package/ffmpeg/Default)
 SECTION:=libs
 CATEGORY:=Libraries
 TITLE+= libraries
 DEPENDS+= +libpthread +zlib
 PROVIDES:= libffmpeg
endef


# Package build suppressed when CONFIG_ALL=y
define Package/libffmpeg-custom
$(call Package/libffmpeg/Default)
 TITLE+= (custom)
 DEPENDS+= @!ALL \
           +FFMPEG_CUSTOM_SELECT_libopus:libopus \
           +FFMPEG_CUSTOM_SELECT_libx264:libx264 \
           +FFMPEG_CUSTOM_SELECT_libmp3lame:lame-lib \
           +FFMPEG_CUSTOM_SELECT_libshine:shine \
           +FFMPEG_CUSTOM_SELECT_libfdk-aac:fdk-aac
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
 VARIANT:=audio-dec
 CONFLICTS:=libffmpeg-full
endef

define Package/libffmpeg-audio-dec/description
$(call Package/ffmpeg/Default/description)
 .
 This package contains FFmpeg shared libraries for audio decoding.
endef


define Package/libffmpeg-full
$(call Package/libffmpeg/Default)
 TITLE+= (full)
 DEPENDS+= \
	+FFMPEG_FULL_BZLIB:libbz2 \
	+FFMPEG_FULL_LZMA:liblzma \
	+FFMPEG_FULL_LIBDRM:libdrm \
	+FFMPEG_FULL_V4L2_REQUEST:libdrm \
	+FFMPEG_FULL_V4L2_REQUEST:libudev \
	+FFMPEG_FULL_VAAPI:libva \
	+FFMPEG_FULL_LIBV4L2:libv4l \
	+FFMPEG_FULL_TLS_GNUTLS:libgnutls \
	+FFMPEG_FULL_TLS_OPENSSL:libopenssl \
	+FFMPEG_FULL_TLS_MBEDTLS:libmbedtls \
	+FFMPEG_FULL_LIBDAV1D:libdav1d \
	+FFMPEG_FULL_LIBOPUS:libopus \
	+FFMPEG_FULL_LIBVORBIS:libvorbis \
	+FFMPEG_FULL_LIBVPX:libvpx \
	+FFMPEG_FULL_LIBWEBP:libwebp \
	+FFMPEG_FULL_LIBSPEEX:libspeex \
	+FFMPEG_FULL_LIBXML2:libxml2 \
	+FFMPEG_FULL_LAME:lame-lib \
	+FFMPEG_FULL_SHINE:shine \
	+FFMPEG_FULL_LIBX264:libx264 \
	+FFMPEG_FULL_FDK_AAC:fdk-aac
 VARIANT:=full
 PROVIDES+=libffmpeg-mini libffmpeg-audio-dec
endef

define Package/libffmpeg-full/config
menu "FFmpeg build configuration"

	comment "Licensing"

	config FFMPEG_FULL_GPL
		bool "Include GPL components (libpostproc, GPL filters)"
		default y
		help
		  Build libffmpeg-full with --enable-gpl. This adds libpostproc
		  and the GPL-licensed filters, and the resulting libraries are
		  distributed under the GPL-2.0-or-later. Kodi requires
		  libpostproc, so leave this enabled for a Kodi build.

	config FFMPEG_FULL_VERSION3
		bool "Allow (L)GPL v3 components"
		default n
		help
		  Sets --enable-version3. Upgrades the licence of the resulting
		  libraries to (L)GPL-3.0-or-later.

	config FFMPEG_FULL_NONFREE
		bool "Allow non-redistributable components"
		default n
		help
		  Sets --enable-nonfree. In almost all cases this prohibits
		  redistribution of the resulting binaries. Use with care.

	comment "Build properties"

	config FFMPEG_X86ASM
		bool "Compile x86 assembly optimizations"
		depends on (x86_64 || (i386 && !(TARGET_x86_geode || TARGET_x86_legacy)))
		default y
		help
		  Needed as NASM is broken with CPU_TYPE=pentium.

	config FFMPEG_FULL_OPTIMIZE_SIZE
		bool "Optimize for size instead of speed"
		default n if x86_64
		default y
		help
		  --enable-small (plus generated instead of hardcoded tables).
		  Disable this for noticeably faster decoding at the cost of a
		  few hundred kB of code and tables.

	config FFMPEG_FULL_PROGRAMS
		bool "Build the command line programs (ffmpeg, ffprobe)"
		default y
		help
		  When disabled only the shared libraries are built; the
		  ffmpeg/ffprobe packages then have nothing to install.

	comment "Hardware acceleration"

	config FFMPEG_FULL_LIBDRM
		bool "DRM support (libdrm, needed for DRM_PRIME zero-copy)"
		default y

	config FFMPEG_FULL_V4L2_M2M
		bool "V4L2 mem2mem (stateful) decoders/encoders"
		default y

	config FFMPEG_FULL_V4L2_REQUEST
		bool "V4L2 Request API (stateless) hwaccels"
		select FFMPEG_FULL_LIBDRM
		default y
		help
		  Stateless V4L2 hardware decoding (cedrus, hantro, rkvdec, ...)
		  exporting DRM_PRIME frames. Pulls in libdrm and libudev.

	config FFMPEG_FULL_VAAPI
		bool "VA-API hardware acceleration"
		default n

	comment "Transport layer security"

	choice
		prompt "TLS backend"
		default FFMPEG_FULL_TLS_MBEDTLS
		help
		  mbedTLS is the default because it is the TLS library OpenWrt
		  itself ships by default (libustream-mbedtls, hostapd-*-mbedtls).
		  Pick the backend that is already in your image to avoid
		  carrying a second TLS library.

		config FFMPEG_FULL_TLS_NONE
			bool "none (no https/tls protocol)"

		config FFMPEG_FULL_TLS_GNUTLS
			bool "GnuTLS"

		config FFMPEG_FULL_TLS_OPENSSL
			bool "OpenSSL"

		config FFMPEG_FULL_TLS_MBEDTLS
			bool "mbedTLS"
	endchoice

	comment "External libraries"

	config FFMPEG_FULL_LIBDAV1D
		bool "AV1 decoding via libdav1d"
		default y
		help
		  FFmpeg has no native software AV1 decoder; its built-in av1
		  decoder only drives hardware acceleration (V4L2 Request API,
		  VA-API). Without libdav1d, AV1 can only be played on hardware
		  with an AV1 decoder block.

	config FFMPEG_FULL_LIBOPUS
		bool "Opus encoding via libopus"
		default y
		help
		  Opus decoding is always available through FFmpeg's native
		  decoder, which is preferred even when libopus is present.
		  libopus adds a production-quality encoder; the native Opus
		  encoder is marked experimental.

	config FFMPEG_FULL_LIBVORBIS
		bool "Vorbis encoding via libvorbis"
		default n

	config FFMPEG_FULL_LIBVPX
		bool "VP8/VP9 encoding via libvpx"
		default n
		help
		  VP8 and VP9 decoding is always available through FFmpeg's
		  native decoders, which are preferred even when libvpx is
		  present. libvpx effectively only adds the encoders.

	config FFMPEG_FULL_LIBWEBP
		bool "WebP encoding via libwebp"
		default n

	config FFMPEG_FULL_LIBSPEEX
		bool "Speex encoding via libspeex"
		default n
		help
		  Speex decoding is always available through FFmpeg's native
		  decoder, which is preferred even when libspeex is present.
		  libspeex effectively only adds the encoder.

	config FFMPEG_FULL_LIBXML2
		bool "XML parsing via libxml2 (DASH/IMF demuxers)"
		default n
		help
		  The DASH and IMF demuxers are the only users of libxml2 and
		  are dropped entirely without it; there is no native fallback.

	config FFMPEG_FULL_LAME
		bool "MP3 encoding via LAME"
		default y if !SOFT_FLOAT
		default n

	config FFMPEG_FULL_SHINE
		bool "Fixed-point MP3 encoding via libshine"
		default y if SOFT_FLOAT
		default n

	config FFMPEG_FULL_LIBX264
		bool "H.264 encoding via libx264"
		depends on FFMPEG_FULL_GPL && BUILD_PATENTED
		default y

	config FFMPEG_FULL_FDK_AAC
		bool "AAC encoding via libfdk-aac"
		depends on FFMPEG_FULL_NONFREE && !FFMPEG_FULL_GPL
		default n
		help
		  The FDK licence is incompatible with the GPL, so this is only
		  offered for a non-GPL, nonfree build. The native FFmpeg AAC
		  encoder is always available.

	comment "System libraries"

	config FFMPEG_FULL_LIBV4L2
		bool "V4L2 capture device via libv4l2 (pixel format conversion)"
		default n
		help
		  The V4L2 capture/output devices of libavdevice work without
		  this, using raw ioctls. libv4l2 adds the v4l-utils userspace
		  layer, mainly libv4lconvert for webcams emitting pixel
		  formats FFmpeg cannot read natively. Not a decoder hwaccel.

	config FFMPEG_FULL_BZLIB
		bool "bzip2 support"
		default y
		help
		  Only used by the Matroska demuxer for bzip2-compressed tracks.
		  Without it such tracks cannot be read; everything else in
		  Matroska is unaffected.

	config FFMPEG_FULL_LZMA
		bool "lzma support"
		default n
		help
		  Only used by the TIFF decoder for LZMA-compressed images.

	config FFMPEG_FULL_ICONV
		bool "iconv support (subtitle charset conversion)"
		default y
		help
		  Uses the iconv implementation of the C library; no additional
		  package is needed on musl.

endmenu
endef

define Package/libffmpeg-full/description
$(call Package/ffmpeg/Default/description)
 .
 This package contains full-featured FFmpeg shared libraries.
endef


define Package/libffmpeg-mini
$(call Package/libffmpeg/Default)
 TITLE+= (mini)
 VARIANT:=mini
 CONFLICTS:=libffmpeg-full
endef

define Package/libffmpeg-mini/description
$(call Package/ffmpeg/Default/description)
 .
 This package contains minimal-featured FFmpeg shared libraries.
endef


# Strip off FPU notation
REAL_CPU_TYPE:=$(call qstrip,$(firstword $(subst +, ,$(CONFIG_CPU_TYPE))))
# Fixup cpu types recognized by ffmpeg configure
REAL_CPU_TYPE:=$(subst octeonplus,octeon+,$(REAL_CPU_TYPE))

# Base configuration, shared by all variants.
#
# --disable-autodetect is what makes the build deterministic: nothing gets
# linked in just because it happens to be present in the shared staging dir.
# Everything wanted has to be requested explicitly below, and a requested
# but missing library fails configure loudly instead of silently vanishing.
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
# explicitly above (--disable-autodetect already implies it, this makes the
# intent readable and survives changes to configure's autodetect list). The
# full variant re-enables bzlib/iconv/lzma and the hwaccels through its
# FFMPEG_FULL_* options below; later flags win.
# v4l2-request and libudev are introduced by patches/120-v4l2-request.patch,
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

ifeq ($(BUILD_VARIANT),full)

  # postproc: libpostproc was removed upstream in FFmpeg 8.0 and is re-added
  # by patches/100-postproc.patch (LibreELEC), which also brings back the
  # --enable/--disable-postproc option; it is GPL-only, so it follows the GPL
  # knob. Kodi hard-requires it.
  # v4l2-request/libudev: options from patches/120-v4l2-request.patch, see
  # the common block above.
  FFMPEG_CONFIGURE+= \
	$(call FFMPEG_OPT,FFMPEG_FULL_GPL,gpl) \
	$(call FFMPEG_OPT,FFMPEG_FULL_GPL,postproc) \
	$(call FFMPEG_OPT,FFMPEG_FULL_VERSION3,version3) \
	$(call FFMPEG_OPT,FFMPEG_FULL_NONFREE,nonfree) \
	$(call FFMPEG_OPT,FFMPEG_FULL_OPTIMIZE_SIZE,small) \
	$(if $(CONFIG_FFMPEG_FULL_OPTIMIZE_SIZE),--disable-hardcoded-tables,--enable-hardcoded-tables) \
	$(call FFMPEG_OPT,FFMPEG_FULL_LIBDRM,libdrm) \
	$(call FFMPEG_OPT,FFMPEG_FULL_V4L2_M2M,v4l2-m2m) \
	$(call FFMPEG_OPT,FFMPEG_FULL_V4L2_REQUEST,v4l2-request) \
	$(call FFMPEG_OPT,FFMPEG_FULL_V4L2_REQUEST,libudev) \
	$(call FFMPEG_OPT,FFMPEG_FULL_VAAPI,vaapi) \
	$(call FFMPEG_OPT,FFMPEG_FULL_LIBV4L2,libv4l2) \
	$(call FFMPEG_OPT,FFMPEG_FULL_TLS_GNUTLS,gnutls) \
	$(call FFMPEG_OPT,FFMPEG_FULL_TLS_OPENSSL,openssl) \
	$(call FFMPEG_OPT,FFMPEG_FULL_TLS_MBEDTLS,mbedtls) \
	$(call FFMPEG_OPT,FFMPEG_FULL_BZLIB,bzlib) \
	$(call FFMPEG_OPT,FFMPEG_FULL_LZMA,lzma) \
	$(call FFMPEG_OPT,FFMPEG_FULL_ICONV,iconv) \
	$(call FFMPEG_OPT,FFMPEG_FULL_LIBDAV1D,libdav1d) \
	$(call FFMPEG_OPT,FFMPEG_FULL_LIBOPUS,libopus) \
	$(call FFMPEG_OPT,FFMPEG_FULL_LIBVORBIS,libvorbis) \
	$(call FFMPEG_OPT,FFMPEG_FULL_LIBVPX,libvpx) \
	$(call FFMPEG_OPT,FFMPEG_FULL_LIBWEBP,libwebp) \
	$(call FFMPEG_OPT,FFMPEG_FULL_LIBSPEEX,libspeex) \
	$(call FFMPEG_OPT,FFMPEG_FULL_LIBXML2,libxml2) \
	$(call FFMPEG_OPT,FFMPEG_FULL_LAME,libmp3lame) \
	$(call FFMPEG_OPT,FFMPEG_FULL_SHINE,libshine) \
	$(call FFMPEG_OPT,FFMPEG_FULL_LIBX264,libx264) \
	$(call FFMPEG_OPT,FFMPEG_FULL_FDK_AAC,libfdk-aac) \
	$(if $(CONFIG_BUILD_PATENTED),, \
		$(call FFMPEG_DISABLE,decoder,$(FFMPEG_PATENTED_DECODERS)) \
		$(call FFMPEG_DISABLE,muxer,$(FFMPEG_PATENTED_MUXERS)) \
		$(call FFMPEG_DISABLE,demuxer,$(FFMPEG_PATENTED_DEMUXERS)) \
		$(call FFMPEG_DISABLE,parser,$(FFMPEG_PATENTED_PARSERS)))

  ifneq ($(CONFIG_FFMPEG_FULL_PROGRAMS),y)
	FFMPEG_CONFIGURE+= --disable-programs
  else
	FFMPEG_CONFIGURE+= \
		--enable-ffmpeg \
		--enable-ffprobe \
		--disable-ffplay
  endif
endif

ifeq ($(BUILD_VARIANT),custom)

  ifeq ($(CONFIG_FFMPEG_CUSTOM_LARGE),y)
	FFMPEG_CONFIGURE+= \
		--disable-small \
		--enable-hardcoded-tables
  else
	FFMPEG_CONFIGURE+= \
		--enable-small \
		--disable-hardcoded-tables
  endif

  FFMPEG_CONFIGURE+= \
	$(call FFMPEG_OPT,FFMPEG_CUSTOM_GPL,gpl) \
	$(call FFMPEG_OPT,FFMPEG_CUSTOM_GPLV3,version3) \
	$(call FFMPEG_OPT,FFMPEG_CUSTOM_NONFREE,nonfree)

  ifneq ($(CONFIG_FFMPEG_CUSTOM_PROGRAMS),y)
      FFMPEG_CONFIGURE+= \
	--disable-programs \
	--disable-avfilter \
	--disable-swresample
  else
      FFMPEG_CONFIGURE+= \
	--enable-avfilter \
	--enable-swresample \
	--enable-ffmpeg \
	--enable-ffprobe \
	--disable-ffplay
  endif

  FFMPEG_CONFIGURE+= \
	--disable-swscale \
	--disable-everything \
	$(call FFMPEG_ENABLE_IF,encoder,$(FFMPEG_CUSTOM_ENCODERS),CONFIG_FFMPEG_CUSTOM_ENCODER) \
	$(call FFMPEG_ENABLE_IF,decoder,$(FFMPEG_CUSTOM_DECODERS),CONFIG_FFMPEG_CUSTOM_DECODER) \
	$(call FFMPEG_ENABLE_IF,muxer,$(FFMPEG_CUSTOM_MUXERS),CONFIG_FFMPEG_CUSTOM_MUXER) \
	$(call FFMPEG_ENABLE_IF,demuxer,$(FFMPEG_CUSTOM_DEMUXERS),CONFIG_FFMPEG_CUSTOM_DEMUXER) \
	$(call FFMPEG_ENABLE_IF,parser,$(FFMPEG_CUSTOM_PARSERS),CONFIG_FFMPEG_CUSTOM_PARSER) \
	$(call FFMPEG_ENABLE_IF,protocol,$(FFMPEG_CUSTOM_PROTOCOLS),CONFIG_FFMPEG_CUSTOM_PROTOCOL) \

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

# postproc (patches/100-postproc.patch) is only built together with libx264
# in the custom variant; make both outcomes explicit
ifeq ($(CONFIG_FFMPEG_CUSTOM_SELECT_libx264),y)
  FFMPEG_CONFIGURE+= \
	--enable-libx264 --enable-encoder=libx264 \
	--enable-postproc
else
  FFMPEG_CONFIGURE+= --disable-postproc
endif

endif

ifeq ($(BUILD_VARIANT),audio-dec)

  FFMPEG_CONFIGURE+= \
	--enable-small \
	--disable-hardcoded-tables \
	--enable-gpl \
	\
	--disable-programs \
	--disable-avdevice \
	--disable-avfilter \
	--disable-postproc \
	--disable-swresample \
	--disable-swscale \
	--disable-everything \
	$(call FFMPEG_ENABLE,decoder,$(FFMPEG_AUDIO_DECODERS)) \
	$(call FFMPEG_ENABLE,demuxer,$(FFMPEG_AUDIO_DEMUXERS)) \
	$(call FFMPEG_ENABLE,protocol,$(FFMPEG_AUDIO_PROTOCOLS)) \
	--disable-decoder=pcm_bluray,pcm_dvd
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

# All variants stage into the same directory, so decide once which one wins
# instead of letting build order decide: full beats mini beats the reduced
# variants. (-full and -mini conflict with each other at install time
# anyway; -custom may legitimately be built alongside them.)
ifeq ($(BUILD_VARIANT),full)
  Build/InstallDev = $(Build/InstallDev/Default)
endif
ifeq ($(BUILD_VARIANT),mini)
  ifeq ($(CONFIG_PACKAGE_libffmpeg-full),)
    Build/InstallDev = $(Build/InstallDev/Default)
  endif
endif
ifeq ($(BUILD_VARIANT),custom)
  ifeq ($(CONFIG_PACKAGE_libffmpeg-full)$(CONFIG_PACKAGE_libffmpeg-mini),)
    Build/InstallDev = $(Build/InstallDev/Default)
  endif
endif
ifeq ($(BUILD_VARIANT),audio-dec)
  ifeq ($(CONFIG_PACKAGE_libffmpeg-full)$(CONFIG_PACKAGE_libffmpeg-mini),)
    Build/InstallDev = $(Build/InstallDev/Default)
  endif
endif

define Package/ffmpeg/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ffmpeg $(1)/usr/bin/ffmpeg
endef

Package/ffmpeg-custom/install = $(Package/ffmpeg/install)

define Package/ffprobe/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ffprobe $(1)/usr/bin/ffprobe
endef

Package/ffprobe-custom/install = $(Package/ffprobe/install)

# ship whatever shared libraries the variant built
define Package/libffmpeg/install/Default
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so.* $(1)/usr/lib/
endef

Package/libffmpeg-full/install = $(Package/libffmpeg/install/Default)
Package/libffmpeg-mini/install = $(Package/libffmpeg/install/Default)
Package/libffmpeg-custom/install = $(Package/libffmpeg/install/Default)
Package/libffmpeg-audio-dec/install = $(Package/libffmpeg/install/Default)

$(eval $(call BuildPackage,ffmpeg))
$(eval $(call BuildPackage,ffprobe))
$(eval $(call BuildPackage,ffmpeg-custom))
$(eval $(call BuildPackage,ffprobe-custom))
$(eval $(call BuildPackage,libffmpeg-audio-dec))
$(eval $(call BuildPackage,libffmpeg-full))
$(eval $(call BuildPackage,libffmpeg-mini))
$(eval $(call BuildPackage,libffmpeg-custom))
