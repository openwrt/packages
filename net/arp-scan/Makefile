#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=arp-scan
PKG_VERSION:=1.9.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/royhills/arp-scan/tar.gz/$(PKG_VERSION)?
PKG_HASH:=b9b75ceaef6348f5951b06c773ec7a243a9e780e160eafebc369f9c27f6a7d3f

PKG_MAINTAINER:=Sergey Urushkin <urusha.v1.0@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later

PKG_FIXUP:=autoreconf

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/arp-scan/default
  SUBMENU:=arp-scan
  SECTION:=net
  CATEGORY:=Network
  URL:=https://github.com/royhills/arp-scan
endef

define Package/arp-scan
$(call Package/arp-scan/default)
  TITLE:=ARP scanner
  DEPENDS:=+libpcap
endef

define Package/arp-scan/description
    ARP scanner
endef

define Package/arp-scan/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/arp-scan $(1)/usr/bin/
endef

define Package/arp-scan/postinst
cat <<EOF

Please install the arp-scan-database package in order to let arp-scan
display additional information about vendor/manufacturer for each
discovered device.

EOF
endef

$(eval $(call BuildPackage,arp-scan))

define Package/arp-scan-database
$(call Package/arp-scan/default)
  TITLE:=MAC database for ARP scanner
endef

define Package/arp-scan-database/description
    MAC database for ARP scanner
endef

define Package/arp-scan-database/install
	$(INSTALL_DIR) $(1)/usr/share/arp-scan
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ieee-iab.txt $(1)/usr/share/arp-scan/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ieee-oui.txt $(1)/usr/share/arp-scan/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/mac-vendor.txt $(1)/usr/share/arp-scan/
endef

define Package/arp-scan-database/postrm
	$(RM) -rf $(1)/usr/share/arp-scan
endef

$(eval $(call BuildPackage,arp-scan-database))
