#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

PKG_NAME:=libeuci
PKG_RELEASE:=2

CMAKE_INSTALL:=1

define Package/$(PKG_NAME)
 SECTION:=libs
 CATEGORY:=Libraries
 DEPENDS:=+libuci
 TITLE:=A warp around libuci, aim to use simple
 MAINTAINER:=Jianhui Zhao <jianhuizhao329@gmail.com>
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_BUILD_DIR)/libeuci.so $(1)/lib
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
