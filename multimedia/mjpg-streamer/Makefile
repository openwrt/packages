#
# Copyright (C) 2006-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mjpg-streamer
PKG_REV:=181
PKG_VERSION:=r$(PKG_REV)
PKG_RELEASE:=1
PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://svn.code.sf.net/p/mjpg-streamer/code/mjpg-streamer
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_PROTO:=svn

include $(INCLUDE_DIR)/package.mk

define Package/mjpg-streamer
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=MJPG-streamer
  DEPENDS:=+libpthread +libjpeg
  URL:=http://mjpg-streamer.wiki.sourceforge.net/
  MENU:=1
endef

define Package/mjpg-streamer/description
 Streaming application for Linux-UVC compatible webcams
endef

define Package/mjpg-streamer/config
  source "$(SOURCE)/Config.in"
endef

EXTRA_CFLAGS += $(TARGET_CPPFLAGS) $(TARGET_LDFLAGS)

define Package/mjpg-streamer/conffiles
/etc/config/mjpg-streamer
endef

define Package/mjpg-streamer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mjpg_streamer $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/mjpg-streamer.config $(1)/etc/config/mjpg-streamer
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mjpg-streamer.init $(1)/etc/init.d/mjpg-streamer
	$(INSTALL_DIR) $(1)/etc/hotplug.d/usb
	$(INSTALL_DATA) ./files/mjpg-streamer.hotplug $(1)/etc/hotplug.d/usb/20-mjpg-streamer
	$(INSTALL_DIR) $(1)/usr/lib
ifeq ($(CONFIG_MJPG_STREAMER_INPUT_FILE),y)
	$(CP) $(PKG_BUILD_DIR)/input_file.so $(1)/usr/lib
endif
ifeq ($(CONFIG_MJPG_STREAMER_INPUT_UVC),y)
	$(CP) $(PKG_BUILD_DIR)/input_uvc.so $(1)/usr/lib
endif
ifeq ($(CONFIG_MJPG_STREAMER_OUTPUT_FILE),y)
	$(CP) $(PKG_BUILD_DIR)/output_file.so $(1)/usr/lib
endif
ifeq ($(CONFIG_MJPG_STREAMER_OUTPUT_HTTP),y)
	$(CP) $(PKG_BUILD_DIR)/output_http.so $(1)/usr/lib
endif
ifeq ($(CONFIG_MJPG_STREAMER_WWW),y)
	$(INSTALL_DIR) $(1)/www/webcam
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/www/* $(1)/www/webcam
endif
endef

$(eval $(call BuildPackage,mjpg-streamer))
