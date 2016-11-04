#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=squeezelite
PKG_VERSION:=1.8.4-743
PKG_RELEASE=1

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:= Ted Hess <thess@kitschensync.net>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ralph-irving/squeezelite.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=e37ed17fed9e11a7346cbe9f1e1deeccc051f42e
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=libflac libvorbis libmad libfaad2 SQUEEZELITE_WMA:libffmpeg-audio-dec

include $(INCLUDE_DIR)/package.mk

define Package/squeezelite/default
    SECTION:=sound
    CATEGORY:=Sound
    TITLE:=Headless squeezebox emulator
    PROVIDES:=squeezelite
    URL:=https://github.com/ralph-irving/squeezelite
    DEPENDS:= +alsa-lib +SQUEEZELITE_RESAMPLE:libsoxr
    MENU:=1
endef

define Package/squeezelite-full
    $(call Package/squeezelite/default)
    TITLE+= (full)
    DEPENDS+= +libflac +libvorbis +libmad +libfaad2 \
              +SQUEEZELITE_WMA:libffmpeg-audio-dec
    VARIANT:=full
endef

define Package/squeezelite-mini
    $(call Package/squeezelite/default)
    TITLE+= (minimal)
    VARIANT:=mini
endef

define Package/squeezelite/config/default

	config SQUEEZELITE_WMA
	    bool "WMA/ALAC decode support"
	    help
		Include WMA and ALAC decoding using ffmpeg
	    default n

	config SQUEEZELITE_RESAMPLE
	    bool "Resample support"
	    help
		Include support for resampling using libsoxr
	    default n

	config SQUEEZELITE_DSD
	    bool "DSD playback over PCM (DoP)"
	    help
		Include support for DSD over PCM for compatible DAC"
	    default n
endef

define Package/squeezelite-full/config
    if PACKAGE_squeezelite-full
	$(call Package/squeezelite/config/default)
    endif
endef

define Package/squeezelite-mini/config
    if PACKAGE_squeezelite-mini
	$(call Package/squeezelite/config/default)
    endif
endef

define Package/squeezelite/description/default
    Squeezelite is a small headless squeezebox emulator for linux using alsa audio output 
    It is aimed at supporting high quality audio at multiple sample rates including 
    44.1/48/88.2/96/176.4/192k/352.8/384kHz 
    Supported codecs: mp3, flac, ogg, aac, (wma and alac via ffmpeg) 
    Native support for PCM builtin
    Optional support of DSD playback via PCM for DoP capable DAC
    Optional resampling to match sound device
endef

define Package/squeezelite/description
    $(call Package/squeezelite/description/default)
    .
    This package has all the audio codecs compiled in.
endef

define Package/squeezelite-mini/description
    $(call Package/squeezelite/description/default)
    .
    This package will dynamically load installed codecs.
endef

#ifeq ($(CONFIG_SQUEEZELITE_WMA),y)
#    PKG_BUILD_DEPENDS+= libffmpeg-audio-dec
#endif

TARGET_CFLAGS+= -Wall -fPIC -O2 -DSELFPIPE

ifeq ($(CONFIG_SQUEEZELITE_WMA),y)
    TARGET_CFLAGS+= -DFFMPEG
endif

ifeq ($(CONFIG_SQUEEZELITE_DSD),y)
    TARGET_CFLAGS+= -DDSD
endif

ifeq ($(CONFIG_SQUEEZELITE_RESAMPLE),y)
    TARGET_CFLAGS+= -DRESAMPLE
endif

TARGET_LDFLAGS+= -lasound -lpthread -lm -lrt

ifeq ($(BUILD_VARIANT),full)
    TARGET_CFLAGS+= -DLINKALL
endif

define Package/squeezelite/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/squeezelite $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/squeezelite.init $(1)/etc/init.d/squeezelite
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/squeezelite.conf $(1)/etc/config/squeezelite
endef

Package/squeezelite-mini/install=$(Package/squeezelite/install)
Package/squeezelite-full/install=$(Package/squeezelite/install)

$(eval $(call BuildPackage,squeezelite-mini))
$(eval $(call BuildPackage,squeezelite-full))
