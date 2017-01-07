#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-lxc
PKG_RELEASE:=20161030

PKG_LICENSE:=Apache-2.0

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-lxc
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LXC management Web UI
  DEPENDS:=+luci-mod-admin-full +lxc +lxc-create +liblxc +rpcd-mod-lxc +getopt +xz
  MAINTAINER:=Petar Koretic <petar.koretic@sartura.hr>
endef

define Package/luci-app-lxc/description
 This package will install LXC management Web UI.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-lxc/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_BIN) \
		./files/controller/lxc.lua \
		$(1)/usr/lib/lua/luci/controller/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/
	$(INSTALL_DATA) \
		./files/view/lxc.htm \
		$(1)/usr/lib/lua/luci/view/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_BIN) \
		./files/model/cbi/lxc.lua \
		$(1)/usr/lib/lua/luci/model/cbi/

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_DATA) \
		./files/lxc.config \
		$(1)/etc/config/lxc

	$(INSTALL_DIR) $(1)/www
	$(CP) -R \
		./files/www/* \
		$(1)/www
endef

$(eval $(call BuildPackage,luci-app-lxc))
