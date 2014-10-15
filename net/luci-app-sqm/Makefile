#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-sqm
PKG_VERSION:=3
PKG_RELEASE:=1
PKG_LICENSE:=GPLv2
LUCI_DIR:=/usr/lib/lua/luci

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-sqm
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=SQM Scripts - LuCI interface
  MAINTAINER:=Toke Høiland-Jørgensen <toke@toke.dk>
  PKGARCH:=all
  DEPENDS:= lua luci-base +sqm-scripts
  SUBMENU:=3. Applications
endef

define Package/luci-app-sqm/description
	Control the simple_qos SQM script
endef

define Build/Compile
endef

define Build/Configure
endef

define Package/luci-app-sqm/install
	$(INSTALL_DIR) $(1)$(LUCI_DIR)/controller $(1)$(LUCI_DIR)/model/cbi
	$(INSTALL_DATA) ./files/sqm-controller.lua $(1)$(LUCI_DIR)/controller/sqm.lua
	$(INSTALL_DATA) ./files/sqm-cbi.lua $(1)$(LUCI_DIR)/model/cbi/sqm.lua
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci-defaults-sqm $(1)/etc/uci-defaults/luci-sqm
endef

define Package/luci-app-sqm/postinst
#!/bin/sh
which uci > /dev/null || exit 0
uci -q get ucitrack.@sqm[0] > /dev/null || {
  uci add ucitrack sqm > /dev/null
  uci set ucitrack.@sqm[0].init=sqm
  uci add_list ucitrack.@firewall[0].affects=sqm
  uci commit
}
endef

define Package/luci-app-sqm/postrm
#!/bin/sh
which uci > /dev/null || exit 0
uci -q get ucitrack.@sqm[0] > /dev/null && {
  uci delete ucitrack.@sqm[0]
  uci del_list ucitrack.@firewall[0].affects=sqm
  uci commit
}
endef

$(eval $(call BuildPackage,luci-app-sqm))
