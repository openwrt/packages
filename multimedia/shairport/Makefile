#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shairport
PKG_VERSION:=2014-05-08
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/abrasive/shairport.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=078b21043cdcef6ffad7452db27f036770b23b0c
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/shairport
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+libpthread +avahi-utils +libopenssl +libao +libavahi-client \
	+alsa-utils
  TITLE:=ShairPort AirPort Express emulator
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

LIBS:=-lao -lm -lcrypto -lpthread -lavahi-common -lavahi-client -lasound

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS) $(LIBS)"

define Package/shairport/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/shairport $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) files/shairport.init $(1)/etc/init.d/shairport
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/shairport.config $(1)/etc/config/shairport
endef

$(eval $(call BuildPackage,shairport))
