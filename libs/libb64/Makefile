#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libb64
PKG_VERSION:=1.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).zip
PKG_SOURCE_URL:=@SF/$(PKG_NAME)/$(PKG_NAME)
PKG_HASH:=20106f0ba95cfd9c35a13c71206643e3fb3e46512df3e2efb2fdbf87116314b2
PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libb64
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=base64 library
  URL:=http://libb64.sourceforge.net/
endef

define Package/libb64/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libb64.so $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libb64.so $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/include/b64
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/include/b64/* $(1)/usr/include/b64/
endef

$(eval $(call BuildPackage,libb64))
