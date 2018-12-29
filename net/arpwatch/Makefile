#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=arpwatch
PKG_VERSION:=2.1a15
PKG_RELEASE:=2

PKG_MAINTAINER:=Michel Belleau <michel.belleau@malaiwah.com>
PKG_LICENSE:=BSD-4-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://distfiles.gentoo.org/distfiles/
PKG_HASH:=c1df9737e208a96a61fa92ddad83f4b4d9be66f8992f3c917e9edf4b05ff5898

include $(INCLUDE_DIR)/package.mk

define Package/arpwatch
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap
  TITLE:=Ethernet station activity monitor
  URL:=http://www-nrg.ee.lbl.gov/
endef

define Package/arpwatch/description
	Ethernet monitor program for keeping track of ethernet/ip address
	pairings.
endef

define Package/arpwatch/conffiles
/etc/arpwatch/arp.dat
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	chmod -R u+w $(PKG_BUILD_DIR)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		ARPDIR=/etc/arpwatch \
		CCOPT="$(TARGET_CFLAGS)" \
		INCLS="-I. $(TARGET_CPPFLAGS)" \
		LIBS="$(TARGET_LDFLAGS) -lpcap"
endef

define Package/arpwatch/install
	$(INSTALL_DIR) $(1)/etc/arpwatch
	$(CP) $(PKG_BUILD_DIR)/arp.dat $(1)/etc/arpwatch/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/arp{watch,snmp} $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/arpwatch.init $(1)/etc/init.d/arpwatch
endef

$(eval $(call BuildPackage,arpwatch))
