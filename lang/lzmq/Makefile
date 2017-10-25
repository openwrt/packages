#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lzmq
PKG_VERSION:=0.4.3
PKG_RELEASE:=1
PKG_MAINTAINER:=Dirk Chang <dirk@kooiot.com>
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/zeromq/lzmq/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=51ec00117b0570db82b1eba7b62e95d7e98c880a028584b195a98b433dd8edd1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/lzmq
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Lua ZeroMQ binding
  URL:=https://github.com/moteus/lzmq/
  DEPENDS:= +lua +libzmq
endef

define Package/lzmq/description
 LZMQ is a Lua binding to ZeroMQ.
endef

CMAKE_OPTIONS += \
	-DUSE_LUA=ON

define Package/lzmq/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lzmq.so $(1)/usr/lib/lua/

	$(INSTALL_DIR) $(1)/usr/lib/lua/lzmq
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lzmq/timer.so $(1)/usr/lib/lua/lzmq
	$(CP) -R $(PKG_BUILD_DIR)/src/lua/lzmq/* $(1)/usr/lib/lua/lzmq
endef

$(eval $(call BuildPackage,lzmq))
