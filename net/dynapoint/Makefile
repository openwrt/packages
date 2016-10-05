#
# Copyright (C) 2016 LEDE project (Tobias Ilte)
#
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=dynapoint
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Tobias Ilte <tobias.ilte@campus.tu-berlin.de>
PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=wireless
    DEPENDS:=+lua +libubus-lua +libuci-lua +libubox-lua +luci-lib-nixio
    MAINTAINER:=Tobias Ilte <tobias.ilte@campus.tu-berlin.de>
    TITLE:=Dynamic access point manager
endef

define Package/$(PKG_NAME)/description
Dynapoint uses LUA scripts to allow dynamic access point creation
and deletion depending on changes of certain network conditions.
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/dynapoint
endef

define Build/Compile
	true
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./src/dynapoint.lua $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./src/dynapoint.init $(1)/etc/init.d/dynapoint
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./src/dynapoint.config $(1)/etc/config/dynapoint	
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

