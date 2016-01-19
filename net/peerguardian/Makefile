#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=peerguardian
PKG_VERSION:=2.3.1
PKG_RELEASE:=1

PKG_SOURCE:=pgl-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/peerguardian
PKG_MD5SUM:=

PKG_BUILD_DIR:=$(BUILD_DIR)/pgl-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/peerguardian
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=P2P
  DEPENDS:=+libnetfilter-queue +zlib
  TARGET_CFLAGS:= -D_GNU_SOURCE
  TITLE:=PeerGuardian for Linux
  URL:=http://phoenixlabs.org/
endef

define Package/peerguardian/description
 PeerGuardian helps protect your privacy by blocking many ranges  of aggressive
 IPs while you use P2P.
endef

define Package/peerguardian/conffiles
/etc/PG.conf
/etc/p2p.p2b.p2p
endef

CONFIGURE_ARGS += \
	--enable-lowmem \
	--without-qt4 \
	--disable-dbus \
	--disable-networkmanager \
	--disable-cron

define Package/peerguardian/install
	$(INSTALL_DIR) $(1)/etc/
	$(CP) $(PKG_INSTALL_DIR)/etc/pgl $(1)/etc/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pglcmd $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/pgld $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pgl $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/peerguardian.init $(1)/etc/init.d/peerguardian
endef

$(eval $(call BuildPackage,peerguardian))
