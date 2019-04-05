#
# Copyright (C) 2014-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shairplay
PKG_VERSION:=2016-01-01
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/juhovh/shairplay.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=ce80e005908f41d0e6fde1c4a21e9cb8ee54007b
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/shairplay
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+libao +libavahi-compat-libdnssd +libltdl +libpthread
  TITLE:=Shairplay
endef

define Package/shairplay/description
  Free portable AirPlay server implementation similar to ShairPort.
endef

define Package/shairplay/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/shairplay $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/shairplay
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/airport.key $(1)/usr/share/shairplay/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/shairplay.init $(1)/etc/init.d/shairplay
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/shairplay.config $(1)/etc/config/shairplay
endef

$(eval $(call BuildPackage,shairplay))
