#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iptraf-ng
PKG_VERSION:=1.2.2
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://src.fedoraproject.org/repo/pkgs/iptraf-ng/v$(PKG_VERSION).tar.gz/sha512/275a345ffd3ab9578c4d159c3a8667326224b4a58b2e7787c4db518b81973d87c04b4b6c5275a721858d01a9b44a0200f8defc06c6f88655aa38d4fa6146ea1d
PKG_HASH:=75fd653745ea0705995c25e6c07b34252ecc2563c6a91b007a3a8c26f29cc252

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_CHECK_FORMAT_SECURITY:=0

include $(INCLUDE_DIR)/package.mk

define Package/iptraf-ng
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libncurses
  TITLE:=A console-based network monitoring program
  URL:=https://github.com/iptraf-ng/iptraf-ng
endef

define Package/iptraf-ng/description
  iptraf-ng is a console-based network statistics utility for Linux. It gathers a
  variety of figures such as TCP connection packet and byte counts, interface
  statistics and activity indicators, TCP/UDP traffic breakdowns, and LAN
  station packet and byte counts.
endef

define Package/iptraf-ng/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	mkdir -p $${IPKG_INSTROOT}/var/log/iptraf-ng \
		 $${IPKG_INSTROOT}/var/run/iptraf-ng \
		 $${IPKG_INSTROOT}/var/lib/iptraf-ng
fi
endef

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -std=gnu99" \
	CPPFLAGS="$(TARGET_CPPFLAGS) -D_GNU_SOURCE" \
	NCURSES_CFLAGS="$(TARGET_CFLAGS)" \
	NCURSES_LDFLAGS="$(TARGET_LDFLAGS) -lncurses -lpanel" \
	iptraf-ng

define Package/iptraf-ng/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/iptraf-ng $(1)/usr/bin/
endef

$(eval $(call BuildPackage,iptraf-ng))
