#
# Copyright (C) 2014-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rtty
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/zhaojh329/rtty.git
PKG_SOURCE_DATE:=2018-1-12
PKG_SOURCE_VERSION:=50d3f4504989b40e6f7a11f0f3cfa9337da156bc
PKG_MIRROR_HASH:=99978aef44919c4ca4c1d91fcf8580beafbbc6ffe0e2219d9797597a46c750ef

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Jianhui Zhao <jianhuizhao329@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rtty
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Terminal
  TITLE:=Access your terminal over the web browser
  DEPENDS:=+libuwsc-nossl +libblobmsg-json
endef

define Package/rtty/description
Access your terminal over the web browser. The 'r' in the name refers to the 'Reverse Proxy' or 'Remote'.
It is composed of the client and the server. You can access any of your terminals through a web browser based on the MAC address.
endef

define Package/rtty/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/rtty $(1)/usr/sbin
	$(INSTALL_BIN) ./files/rtty.init $(1)/etc/init.d/rtty
	$(INSTALL_CONF) ./files/rtty.config $(1)/etc/config/rtty
endef

$(eval $(call BuildPackage,rtty))
