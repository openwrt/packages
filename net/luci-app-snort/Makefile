#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-snort
PKG_RELEASE:=20150125

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-snort
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Snort Web UI
  DEPENDS:=+luci-mod-admin-full +snort
endef

define Package/luci-app-snort/description
 This package will install Snort Web UI.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-snort/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_BIN) \
		./files/controller/snort-controller.lua \
		$(1)/usr/lib/lua/luci/controller/snort.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_BIN) \
		./files/model/cbi/snort-cbi.lua \
		$(1)/usr/lib/lua/luci/model/cbi/snort.lua
endef

$(eval $(call BuildPackage,luci-app-snort))
