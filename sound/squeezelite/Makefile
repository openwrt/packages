include $(TOPDIR)/rules.mk

PKG_NAME:=squeezelite
PKG_VERSION:=1.8
PKG_RELEASE=1

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:= Andrew Kazakov <squeezewrt.ak@gmail.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://code.google.com/p/squeezelite/
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=8b8dfe6918ebe45ade5f3d9b68d453d7b8128d99
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/squeezelite
    SECTION:=sound
    CATEGORY:=Sound
    TITLE:=Headless squeezebox emulator
    URL:=https://code.google.com/p/squeezelite/
    DEPENDS:= +alsa-lib \
              +libflac +libvorbis +libmad +libfaad2 \
              +SQUEEZELITE_WMA:libffmpeg-audio-dec +SQUEEZELITE_RESAMPLE:libsoxr
    MENU:=1
endef

define Package/squeezelite/config
    if PACKAGE_squeezelite

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

    endif
endef

define Package/squeezelite/description
    Squeezelite is a small headless squeezebox emulator for linux using alsa audio output 
    It is aimed at supporting high quality audio at multiple sample rates including 
    44.1/48/88.2/96/176.4/192k/352.8/384kHz 
    Optional support of DSD playback via PCM for DoP capable DAC
    Optional resampling to match sound device
endef

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

define Package/squeezelite/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/squeezelite $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/squeezelite $(1)/etc/init.d/squeezelite
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/squeezelite $(1)/etc/config/squeezelite
endef

$(eval $(call BuildPackage,squeezelite))
