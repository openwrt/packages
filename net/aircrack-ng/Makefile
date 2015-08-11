#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=aircrack-ng
PKG_VERSION:=1.2-rc2
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://download.aircrack-ng.org/ \
		http://archive.aircrack-ng.org/aircrack-ng/$(PKG_VERSION)/
PKG_MD5SUM:=ebe9d537f06f4d6956213af09c4476da

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_MAINTAINER:=Rick Farina <zerochaos@gentoo.org>

include $(INCLUDE_DIR)/package.mk

define Package/aircrack-ng
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap +libpthread +libopenssl +libnl +wireless-tools +ethtool
  TITLE:=WLAN tools for breaking 802.11 WEP/WPA keys
  URL:=http://www.aircrack-ng.org/
  SUBMENU:=wireless
endef

define Package/aircrack-ng/description
  WLAN tools for breaking 802.11 WEP/WPA keys
endef

MAKE_FLAGS += prefix=/usr \
	libnl=true \
	sqlite=false \
	unstable=false \
	OSNAME=Linux

define Package/aircrack-ng/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,aircrack-ng))
