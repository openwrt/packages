#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-itus
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-itus
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=ITUS Status menu
  MAINTAINER:=Luka Perkov <luka.perkov@satura.hr>
endef

define Package/luci-app-itus/description
	ITUS Status menu
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-itus/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_BIN) \
		./files/controller/itus-controller.lua \
		$(1)/usr/lib/lua/luci/controller/itus.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_BIN) \
		./files/model/cbi/itus-cbi.lua \
		$(1)/usr/lib/lua/luci/model/cbi/itus.lua

	$(INSTALL_DIR) $(1)/etc/itus/
	$(INSTALL_CONF) ./files/advanced.conf $(1)/etc/itus/

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/itus.config $(1)/etc/config/itus
endef

$(eval $(call BuildPackage,luci-app-itus))
