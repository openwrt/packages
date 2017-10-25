#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-mwan3
PKG_VERSION:=1.4
PKG_RELEASE:=6
PKG_MAINTAINER:=Aedan Renner <chipdankly@gmail.com>
PKG_LICENSE:=GPLv2

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-mwan3
  SECTION:=LuCI
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI support for the MWAN3 multiwan hotplug script
  DEPENDS:=+mwan3 +luci-mod-admin-full +luci-app-firewall +luci-lib-nixio
  PKGARCH:=all
  MAINTAINER:=Aedan Renner <chipdankly@gmail.com>
endef

define Package/luci-app-mwan3/description
Hotplug script which makes configuration of multiple WAN interfaces simple and
manageable with loadbalancing/failover support for up to 250 physical or logical
WAN interfaces, connection tracking and an easy to manage traffic ruleset
endef

define Build/Compile
endef

define Package/luci-app-mwan3/install
	$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,luci-app-mwan3))
