#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=arp-scan
PKG_VERSION:=1.9.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/royhills/arp-scan/tar.gz/$(PKG_VERSION)?
PKG_HASH:=aa9498af84158a315b7e0ea6c2cddfa746660ca3987cbe7e32c0c90f5382d9d2

PKG_MAINTAINER:=Sergey Urushkin <urusha.v1.0@gmail.com>
PKG_LICENSE:=GPL-3.0

PKG_FIXUP:=autoreconf

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/arp-scan
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ARP scanner
  DEPENDS:=+libpcap
  URL:=https://github.com/royhills/arp-scan
  PKG_MAINTAINER:=Sergey Urushkin <urusha.v1.0@gmail.com>
endef

define Package/arp-scan/description
    ARP scanner
endef

define Package/arp-scan/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/arp-scan $(1)/usr/bin/
endef

$(eval $(call BuildPackage,arp-scan))
