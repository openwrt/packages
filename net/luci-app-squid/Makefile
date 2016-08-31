#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-squid
PKG_RELEASE:=20150608

PKG_LICENSE:=Apache-2.0

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-squid
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Squid Web UI
  DEPENDS:=+luci-mod-admin-full +squid
  MAINTAINER:=Marko Ratkaj <marko.ratkaj@sartura.hr>
endef

define Package/luci-app-squid/description
 This package will install Squid Web UI.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-squid/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_BIN) \
		./files/squid-controller.lua \
		$(1)/usr/lib/lua/luci/controller/squid.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_BIN) \
		./files//squid-cbi.lua \
		$(1)/usr/lib/lua/luci/model/cbi/squid.lua
endef

$(eval $(call BuildPackage,luci-app-squid))
