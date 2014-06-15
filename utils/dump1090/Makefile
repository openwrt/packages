#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=dump1090
PKG_VERSION:=2013-02-04
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/antirez/dump1090.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=ff0fe38722c768c7269afa733790a2b968ea3099
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_LICENSE:=BSD-3c

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/dump1090
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Mode S decoder for the Realtek RTL2832U
  URL:=https://github.com/antirez/dump1090
  DEPENDS:=+libpthread +librtlsdr
endef


define Package/dump1090/description
 Dump1090 is a Mode S decoder specifically designed for RTLSDR devices.
 Embedded HTTP server that displays the currently detected aircrafts on
 Google Maps. Network output in Basestation and AVR formats.
endef

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)"

define Package/dump1090/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/dump1090 $(1)/usr/bin

	$(INSTALL_DIR) $(1)/usr/share/dump1090
	$(CP) $(PKG_BUILD_DIR)/gmap.html $(1)/usr/share/dump1090
endef

$(eval $(call BuildPackage,dump1090))
