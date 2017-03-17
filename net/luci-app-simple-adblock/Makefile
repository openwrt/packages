# Copyright (c) 2017 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-simple-adblock
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0+
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-simple-adblock
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Simple Adblock Web UI
  DEPENDS:=+luci-mod-admin-full +simple-adblock
  PKGARCH:=all
endef

define Package/luci-app-simple-adblock/description
 This package will install Simple Adblock Web UI.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-simple-adblock/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_BIN) ./luasrc/controller/simpleadblock.lua  $(1)/usr/lib/lua/luci/controller/simpleadblock.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_BIN) ./luasrc/model/cbi/simpleadblock.lua $(1)/usr/lib/lua/luci/model/cbi/simpleadblock.lua
endef

$(eval $(call BuildPackage,luci-app-simple-adblock))