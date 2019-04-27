#
# Copyright (C) 2019 Jianhui Zhao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lua-ev
PKG_RELEASE:=1

PKG_SOURCE_URL=https://github.com/brimworks/lua-ev.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE=2015-8-4
PKG_SOURCE_VERSION:=339426fbe528f11cb3cd1af69a88f06bba367981
PKG_MIRROR_HASH:=fe138f05845d549998443628e1b63e07d797977548a30e75305085cca4b25567

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=

PKG_MAINTAINER:=Jianhui Zhao <jianhuizhao329@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/lua-ev
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=lua-ev
  URL:=https://github.com/brimworks/lua-ev
  DEPENDS:=+lua +libev
endef

define Package/lua-ev/description
  Lua integration with libev.
endef

define Package/lua-ev/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ev.so $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lua-ev))
