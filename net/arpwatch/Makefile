#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=arpwatch
PKG_VERSION:=2.1a15
PKG_RELEASE:=5
PKG_MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
PKG_LICENSE:=BSD-4-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://ftp.free.fr/.mirrors1/ftp.gentoo.org/distfiles/
PKG_MD5SUM:=cebfeb99c4a7c2a6cee2564770415fe7
PKG_USERID:=arpwatch:nullmailer

# use a subdirectory to prevent configure for finding libpcap build dir
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)

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
/etc/config/arpwatch
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
		LIBS="$(TARGET_LDFLAGS) -lpcap" \
		all
endef

define Package/arpwatch/install
	$(INSTALL_DIR) $(1)/etc/arpwatch $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/arp{watch,snmp} $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/arpwatch.init $(1)/etc/init.d/arpwatch
	$(INSTALL_CONF) ./files/arpwatch $(1)/etc/config/arpwatch
endef

$(eval $(call BuildPackage,arpwatch))
