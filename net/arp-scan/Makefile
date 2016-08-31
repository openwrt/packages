#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=arp-scan
PKG_VERSION:=1.9-40-g69b2f70
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0
PKG_MAINTAINER:=Sergey Urushkin <urusha.v1.0@gmail.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/royhills/arp-scan.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=69b2f70588565385f3a61d9b1f100f01747cd5e1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

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
