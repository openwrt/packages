include $(TOPDIR)/rules.mk

PKG_NAME:=squeezelite
PKG_VERSION:=1.8
PKG_RELEASE=1
PKG_LICENSE:=GPL-2.0+
PKG_MAINTAINER:= Andrew Kazakov <squeezewrt.ak@gmail.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://code.google.com/p/squeezelite/
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=8b8dfe6918ebe45ade5f3d9b68d453d7b8128d99
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_BUILD_DEPENDS:=alsa-lib libflac libmad libvorbis libfaad2 libffmpeg-mini

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/$(PKG_NAME)
    SECTION:=sound
    CATEGORY:=Sound
    TITLE:=Headless squeezebox emulator for linux/osx/windows
    URL:=https://code.google.com/p/squeezelite/
    DEPENDS:= +alsa-lib +kmod-usb-audio
    MENU:=1
endef

define Package/$(PKG_NAME)/config
    if PACKAGE_squeezelite

	config SQUEEZELITE_FLAC
	    bool "FLAC decode support"
	    select PACKAGE_libflac
	    help
		libflac will be included in the image
	    default n

	config SQUEEZELITE_MAD
	    bool "MP3 decode support"
	    select PACKAGE_libmad
	    help
		libmad will be included in the image
	    default n

	config SQUEEZELITE_OGG
	    bool "OGG decode support"
	    select PACKAGE_libvorbis
	    help
		libvorbis will be included in the image
	    default n

	config SQUEEZELITE_AAC
	    bool "AAC decode support"
	    select PACKAGE_libfaad2
	    help
		libfaad2 will be included in the image
	    default n

	config SQUEEZELITE_WMA
	    bool "WMA and ALAC decode support"
	    select PACKAGE_libffmpeg-mini
	    help
		libffmpeg-mini will be compiled and included in the image
	    default n

    endif
endef

define Package/$(PKG_NAME)/description
    Squeezelite is a small headless squeezebox emulator for linux using alsa audio output 
    and other platforms using portaudio. It is aimed at supporting high quality audio 
    including usb dac based output at multiple sample rates including 
    44.1/48/88.2/96/176.4/192k/352.8/384kHz 
    Native support of dsd playback to dop capable dac or via conversion to pcm and resampling
endef

TARGET_CFLAGS+= -Wall -fPIC -O2 -DSELFPIPE -DDSD -DFFMPEG

TARGET_LDFLAGS+= -lasound -lpthread -lm -lrt

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/squeezelite $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/squeezelite $(1)/etc/init.d/squeezelite
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/squeezelite $(1)/etc/config/squeezelite
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
