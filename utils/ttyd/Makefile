#
# Copyright (C) 2016 Shuanglei Tao <tsl0922@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ttyd
PKG_VERSION:=1.5.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/tsl0922/ttyd/tar.gz/$(PKG_VERSION)?
PKG_HASH:=817d33d59834f9a76af99f689339722fc1ec9f3c46c9a324665b91cb44d79ee8

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Shuanglei Tao <tsl0922@gmail.com>

PKG_BUILD_DEPENDS:=vim/host
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ttyd
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=Command-line tool for sharing terminal over the web
	DEPENDS:=+libopenssl +libjson-c +libpthread +libwebsockets-full
	URL:=https://github.com/tsl0922/ttyd
	SUBMENU:=Terminal
endef

define Package/ttyd/description
ttyd is a command-line tool for sharing terminal over the web.
endef

define Package/ttyd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ttyd $(1)/usr/bin/
endef

$(eval $(call BuildPackage,ttyd))
