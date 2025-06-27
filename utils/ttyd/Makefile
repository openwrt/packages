#
# Copyright (C) 2016 Shuanglei Tao <tsl0922@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ttyd
PKG_VERSION:=1.7.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/tsl0922/ttyd/tar.gz/$(PKG_VERSION)?
PKG_HASH:=c9cf5eece52d27c5d728000f11315d36cb400c6948d1964a34a7eae74b454099

PKG_MAINTAINER:=Shuanglei Tao <tsl0922@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:ttyd_project:ttyd

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ttyd
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=Command-line tool for sharing terminal over the web
	DEPENDS:=+libcap +libopenssl +libjson-c +libuv +zlib +libwebsockets-full
	URL:=https://github.com/tsl0922/ttyd
	SUBMENU:=Terminal
endef

define Package/ttyd/description
ttyd is a command-line tool for sharing terminal over the web.
endef

define Package/ttyd/conffiles
/etc/config/ttyd
endef

define Package/ttyd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ttyd $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/ttyd.config $(1)/etc/config/ttyd
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/ttyd.init $(1)/etc/init.d/ttyd
endef

$(eval $(call BuildPackage,ttyd))
