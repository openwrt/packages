#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-dansguardian
PKG_RELEASE:=20150121

PKG_LICENSE:=Apache-2.0

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-dansguardian
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=DansGuardian Web UI
  DEPENDS:=+luci-mod-admin-full +dansguardian
  MAINTAINER:=Luka Perkov <luka@openwrt.org>
endef

define Package/luci-app-dansguardian/description
 This package will install DansGuardian Web UI.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-dansguardian/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_BIN) \
		./files/dansguardian-controller.lua \
		$(1)/usr/lib/lua/luci/controller/dansguardian.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_BIN) \
		./files//dansguardian-cbi.lua \
		$(1)/usr/lib/lua/luci/model/cbi/dansguardian.lua
endef

$(eval $(call BuildPackage,luci-app-dansguardian))
