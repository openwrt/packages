#
# Copyright (C) 2013-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shairport
PKG_VERSION:=2014-10-28
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/abrasive/shairport.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=d679d19a4bd66cc220dabfd23ad748c34e95995c
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSES

include $(INCLUDE_DIR)/package.mk

define Package/shairport
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+libpthread +libopenssl +libavahi-client +alsa-lib
  TITLE:=ShairPort AirPort Express emulator (un-maintained)
endef

define Package/shairport/description
  This program emulates an AirPort Express for the purpose of streaming
  music from iTunes and compatible iPods. It implements a server for the
  Apple RAOP protocol.
  ShairPort does not support AirPlay v2 (video and photo streaming).

  It supports multiple simultaneous streams, if your audio output chain
  (as detected by libao) does so.
endef

TARGET_CFLAGS += $(FPIC)

LIBS:=-lm -lcrypto -lpthread -lavahi-common -lavahi-client -lasound

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS) $(LIBS)"

define Package/shairport/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/shairport $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) files/shairport.init $(1)/etc/init.d/shairport
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/shairport.config $(1)/etc/config/shairport
endef

$(eval $(call BuildPackage,shairport))
