#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ibrdtnd
PKG_VERSION:=0.12.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.ibr.cs.tu-bs.de/projects/ibr-dtn/releases
PKG_MD5SUM:=8dad5ebbcfaa4c16ba151c9c289066c3
PKG_MAINTAINER:=Johannes Morgenroth <morgenroth@ibr.cs.tu-bs.de>
PKG_LICENSE:=Apache-2.0

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/ibrdtnd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+dtndht +ibrdtn +libsqlite3
  TITLE:=DTN Deamon
endef

define Package/ibrdtnd/conffiles
/etc/config/ibrdtn
endef

define Package/ibrdtnd/description
 The implementation of the bundle protocol of the IBR (TU Braunschweig).
endef

CONFIGURE_ARGS += \
	--with-tls \
	--with-sqlite \
	--without-wifip2p \
	--without-vmime \
	--disable-libdaemon

define Package/ibrdtnd/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/dtnd $(1)/usr/sbin/
	$(INSTALL_BIN) files/safety-wrapper.sh $(1)/usr/sbin/dtnd-safety-wrapper.sh
	$(INSTALL_DIR) $(1)/usr/share/ibrdtn/
	$(INSTALL_BIN) files/build-config.sh $(1)/usr/share/ibrdtn/build-config.sh
	$(INSTALL_BIN) files/mkcontainer.sh $(1)/usr/share/ibrdtn/mkcontainer.sh
	$(INSTALL_BIN) files/mountcontainer.sh $(1)/usr/share/ibrdtn/mountcontainer.sh
	$(INSTALL_BIN) files/systemcheck.sh $(1)/usr/share/ibrdtn/systemcheck.sh
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) files/ibrdtn.init $(1)/etc/init.d/ibrdtn
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/ibrdtn.uci $(1)/etc/config/ibrdtn
endef

$(eval $(call BuildPackage,ibrdtnd))
