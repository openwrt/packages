#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=horst
PKG_VERSION:=5.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=git://github.com/br101/horst.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=22f4be94e839c58ac85ebdc2359b813fd5f68dfd71e1b0c9ed9545020d1abc7d

PKG_MAINTAINER:=Bruno Randolf <br1@einfach.org>
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS += DEBUG=1 LIBNL=tiny

define Package/horst
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=wireless
	DEPENDS:=+libncurses +libnl-tiny
	MAINTAINER:=Bruno Randolf <br1@einfach.org>
	TITLE:=Highly Optimized 802.11 Radio Scanning Tool
	URL:=http://br1.einfach.org/tech/horst/
endef

define Package/horst/description
	[horst] is a scanning and analysis tool for 802.11 wireless networks
	and especially IBSS (ad-hoc) mode and mesh networks (OLSR).
endef

define Package/horst/conffiles
/etc/config/horst
endef

define Package/horst/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/horst $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/horst.sh $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./horst.init $(1)/etc/init.d/horst
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./horst.config $(1)/etc/config/horst
endef

$(eval $(call BuildPackage,horst))
