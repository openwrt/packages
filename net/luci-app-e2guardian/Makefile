#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-e2guardian
PKG_RELEASE:=20150520

PKG_LICENSE:=Apache-2.0

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-e2guardian
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=E2Guardian Web UI
  DEPENDS:=+luci-mod-admin-full +e2guardian
  MAINTAINER:=Marko Ratkaj <marko.ratkaj@sartura.hr>
endef

define Package/luci-app-e2guardian/description
 This package will install E2Guardian Web UI.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-e2guardian/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_BIN) \
		./files/e2guardian-controller.lua \
		$(1)/usr/lib/lua/luci/controller/e2guardian.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_BIN) \
		./files//e2guardian-cbi.lua \
		$(1)/usr/lib/lua/luci/model/cbi/e2guardian.lua
endef

$(eval $(call BuildPackage,luci-app-e2guardian))
