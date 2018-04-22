#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=aircrack-ng
PKG_VERSION:=1.2
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://download.aircrack-ng.org
PKG_HASH:=794ffed5400f35cb78f3466eabb47546f050e0ac35287c174acce60763a0fa7c

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

PKG_MAINTAINER:=Rick Farina <zerochaos@gentoo.org>

include $(INCLUDE_DIR)/package.mk

define Package/aircrack-ng
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap +libpthread +libopenssl +libnl-core +libnl-genl +zlib
  TITLE:=WLAN tools (without airmon-ng) for breaking 802.11 WEP/WPA keys
  URL:=http://www.aircrack-ng.org/
  SUBMENU:=wireless
endef

define Package/aircrack-ng/description
  WLAN tools for breaking 802.11 WEP/WPA keys
endef

define Package/airmon-ng
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+wireless-tools +ethtool +procps-ng +CONFIG_PCI_SUPPORT:pciutils +CONFIG_USB_SUPPORT:usbutils
  TITLE:=Bash script designed to turn wireless cards into monitor mode.
  URL:=http://www.aircrack-ng.org/
  SUBMENU:=wireless
endef

define Package/airmon-ng/description
  Bash script designed to turn wireless cards into monitor mode.
endef

CONFIGURE_ARGS += \
	--with-gnu-ld \
	--with-experimental \
	--without-sqlite3 \
	--without-gcrypt \
	--without-opt

define Package/aircrack-ng/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin/
	rm -f $(1)/usr/sbin/airmon-ng
endef

define Package/airmon-ng/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/airmon-ng $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,aircrack-ng))
$(eval $(call BuildPackage,airmon-ng))
