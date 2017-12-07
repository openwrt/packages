#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=ap51-flash
PKG_VERSION:=2017-12-07
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ap51-flash/ap51-flash.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=f94f9c99711d14a3c0186318d822d67d9d0ce391
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=15786a0ecae9be5ed4e8f32940624d1a1c83da924294df08003616a863947074
PKG_MAINTAINER:=Russell Senior <russell@personaltelco.net>
PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=LICENSES/preferred/GPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/ap51-flash
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=A tool for flashing (nearly) all ap51/ap61 based routers
  URL:=http://dev.cloudtrax.com/wiki/ap51-flash-station
endef

# pass optimization flags
MAKE_FLAGS += \
	REVISION="$(PKG_VERSION)" \
	ap51-flash

define Package/ap51-flash/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d $(1)/usr/sbin \
		$(1)/usr/lib/ap51-flash
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ap51-flash $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/ap51-flash.init $(1)/etc/init.d/ap51-flash
	$(INSTALL_BIN) ./files/ap51-flash.sh $(1)/usr/lib/ap51-flash/ap51-flash.sh
	$(INSTALL_DATA) ./files/ap51-flash.config $(1)/etc/config/ap51-flash
endef

define Package/ap51-flash/conffiles
/etc/config/ap51-flash
endef

$(eval $(call BuildPackage,ap51-flash))
