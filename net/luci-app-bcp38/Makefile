#
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-bcp38
PKG_VERSION:=2
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
LUCI_DIR:=/usr/lib/lua/luci

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-bcp38
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=BCP38 LuCI interface
  MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
  PKGARCH:=all
  DEPENDS:= lua luci-base +bcp38
  SUBMENU:=3. Applications
endef

define Package/luci-app-bcp38/description
	Control BCP38 subnet blocking
endef

define Build/Compile
endef

define Build/Configure
endef

define Package/luci-app-bcp38/install
	$(INSTALL_DIR) $(1)$(LUCI_DIR)/controller $(1)$(LUCI_DIR)/model/cbi
	$(INSTALL_DATA) ./files/bcp38-controller.lua $(1)$(LUCI_DIR)/controller/bcp38.lua
	$(INSTALL_DATA) ./files/bcp38-cbi.lua $(1)$(LUCI_DIR)/model/cbi/bcp38.lua
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci-defaults-bcp38 $(1)/etc/uci-defaults/luci-bcp38
endef

define Package/luci-app-bcp38/postinst
#!/bin/sh
[ -x /etc/uci-defaults/luci-bcp38 ] && /etc/uci-defaults/luci-bcp38 || exit 0
endef

define Package/luci-app-bcp38/postrm
#!/bin/sh
uci delete ucitrack.@bcp38[0]
uci commit
endef

$(eval $(call BuildPackage,luci-app-bcp38))
