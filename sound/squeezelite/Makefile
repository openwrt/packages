#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=squeezelite
PKG_VERSION:=1.9.9-1432
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ralph-irving/squeezelite
PKG_SOURCE_VERSION:=575b59398dd19945d2038474062240fc527407fb
PKG_MIRROR_HASH:=d85c7cf1f57bee295fff263fa2c7425e1ba47394f7f82c84efa2968c0858ec3b

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE.txt

PKG_BUILD_DEPENDS:=faad2 ffmpeg flac libsoxr libvorbis openssl opusfile
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/squeezelite/default
    SECTION:=sound
    CATEGORY:=Sound
    TITLE:=Headless squeezebox emulator
    PROVIDES:=squeezelite
    URL:=https://github.com/ralph-irving/squeezelite
    DEPENDS:=+alsa-lib
endef

define Package/squeezelite-full
    $(call Package/squeezelite/default)
    TITLE+= (full)
    VARIANT:=full
    DEPENDS+= +libfaad2 +libffmpeg-audio-dec +libflac +libmpg123 \
              +libopenssl +libopusfile +libsoxr +libvorbis
endef

define Package/squeezelite-dynamic
    $(call Package/squeezelite/default)
    TITLE+= (dynamic)
    VARIANT:=dynamic
    DEPENDS+= +libmpg123
endef

define Package/squeezelite-custom
    $(call Package/squeezelite/default)
    TITLE+= (custom)
    VARIANT:=custom
    DEPENDS+= @!ALL \
              +SQUEEZELITE_AAC:libfaad2 \
              +SQUEEZELITE_FLAC:libflac \
              +SQUEEZELITE_MP3_MAD:libmad \
              +SQUEEZELITE_MP3_MPG123:libmpg123 \
              +SQUEEZELITE_OPUS:libopusfile \
              +SQUEEZELITE_RESAMPLE:libsoxr \
              +SQUEEZELITE_SSL:libopenssl \
              +SQUEEZELITE_VORBIS:libvorbis \
              +SQUEEZELITE_VORBIS_TREMOR:libvorbisidec \
              +SQUEEZELITE_WMA_ALAC:libffmpeg-audio-dec
    MENU:=1
endef

define Package/squeezelite-custom/config
	if PACKAGE_squeezelite-custom
		config SQUEEZELITE_AAC
		    bool "AAC codec support"
		    help
			AAC codec support
		    default n

		config SQUEEZELITE_DSD
		    bool "DSD playback over PCM (DoP)"
		    help
			Include support for DSD over PCM for compatible DAC
		    default n

		config SQUEEZELITE_FLAC
		    bool "FLAC codec support"
		    help
			FLAC codec support
		    default n

		config SQUEEZELITE_MP3_MAD
		    bool "MP3 codec support (libmad)"
		    help
			MP3 codec support (libmad)
		    default n

		config SQUEEZELITE_MP3_MPG123
		    bool "MP3 codec support (libmpg123)"
		    help
			MP3 codec support (libmpg123)
		    default n

		config SQUEEZELITE_OPUS
		    bool "Opus codec support"
		    help
			Opus codec support
		    default n

		config SQUEEZELITE_RESAMPLE
		    bool "Resample support"
		    help
			Include support for resampling using libsoxr
		    default n

		config SQUEEZELITE_SSL
		    bool "SSL/TLS support"
		    help
			Include SSL/TLS support for use with e.g. https media URLs
		    default n

		config SQUEEZELITE_VORBIS
		    bool "Vorbis codec support"
		    help
			Vorbis codec support
		    default n

		config SQUEEZELITE_VORBIS_TREMOR
		    bool "Vorbis codec support (Tremor)"
		    help
			Vorbis codec support (Tremor (libvorbisidec))
		    default n

		config SQUEEZELITE_WMA_ALAC
		    bool "WMA/ALAC decode support"
		    help
			WMA and ALAC codec support
		    default n
	endif
endef

define Package/squeezelite/description/default
    Squeezelite is a small headless squeezebox emulator for linux using alsa audio output

    It is aimed at supporting high quality audio at multiple sample rates including
    44.1/48/88.2/96/176.4/192/352.8/384 kHz
endef

define Package/squeezelite-full/description
    $(call Package/squeezelite/description/default)
    This package includes all features and codecs.

    Supported codecs: AAC, AIFF, ALAC, FLAC, MP3, Ogg, Opus, PCM and WMA
    Features:
      * Resampling to match sound device
      * DSD playback via PCM for DoP capable DAC
endef

define Package/squeezelite-dynamic/description
    $(call Package/squeezelite/description/default)
    This package includes some basic functionality, and it's possible to
    add more features and codecs by manually installing additional libraries.

    Built in codec support: AIFF, MP3, PCM

    The following features and codecs can be enabled by installing additional
    libraries (library package name in parentheses):
      * Resampling (libsoxr)
      * Codecs:
        * AAC (libfaad2)
        * FLAC (libflac)
        * Ogg (libvorbis or libvorbisidec)
        * Opus (libopusfile)
        * WMA and ALAC (libffmpeg-audio-dec)
endef

define Package/squeezelite-custom/description
    $(call Package/squeezelite/description/default)
    This package allows for customizing squeezelite with specific codecs and features.
endef

ifeq ($(BUILD_VARIANT),full)
    opts+= -DLINKALL
    opts+= -DDSD -DFFMPEG -DOPUS -DRESAMPLE -DUSE_SSL
    opts+= -DNO_MAD
    TARGET_CFLAGS+=-I$(STAGING_DIR)/usr/include/opus
else ifeq ($(BUILD_VARIANT),dynamic)
    opts+= -DFFMPEG -DOPUS -DRESAMPLE -DUSE_SSL
    opts+= -DNO_MAD
    TARGET_CFLAGS+=-I$(STAGING_DIR)/usr/include/opus
else ifeq ($(BUILD_VARIANT),custom)
ifneq ($(CONFIG_SQUEEZELITE_AAC),y)
    opts+= -DNO_FAAD
endif

ifeq ($(CONFIG_SQUEEZELITE_DSD),y)
    opts+= -DDSD
endif

ifneq ($(CONFIG_SQUEEZELITE_MP3_MAD),y)
    opts+= -DNO_MAD
endif

ifneq ($(CONFIG_SQUEEZELITE_MP3_MPG123),y)
    opts+= -DNO_MPG123
endif

ifeq ($(CONFIG_SQUEEZELITE_OPUS),y)
    opts+= -DOPUS
    TARGET_CFLAGS+=-I$(STAGING_DIR)/usr/include/opus
endif

ifeq ($(CONFIG_SQUEEZELITE_RESAMPLE),y)
    opts+= -DRESAMPLE
endif

ifeq ($(CONFIG_SQUEEZELITE_SSL),y)
    opts+= -DUSE_SSL
endif

ifeq ($(CONFIG_SQUEEZELITE_WMA_ALAC),y)
    opts+= -DFFMPEG
endif

endif

MAKE_FLAGS+=OPTS="$(opts)"

define Package/squeezelite/conffiles
/etc/config/squeezelite
endef

Package/squeezelite-full/conffiles = $(Package/squeezelite/conffiles)
Package/squeezelite-dynamic/conffiles = $(Package/squeezelite/conffiles)
Package/squeezelite-custom/conffiles = $(Package/squeezelite/conffiles)

define Package/squeezelite/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/squeezelite $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/squeezelite.init $(1)/etc/init.d/squeezelite
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/squeezelite.conf $(1)/etc/config/squeezelite
endef

Package/squeezelite-full/install=$(Package/squeezelite/install)
Package/squeezelite-dynamic/install=$(Package/squeezelite/install)
Package/squeezelite-custom/install=$(Package/squeezelite/install)

$(eval $(call BuildPackage,squeezelite-full))
$(eval $(call BuildPackage,squeezelite-dynamic))
$(eval $(call BuildPackage,squeezelite-custom))
