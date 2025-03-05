#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nbd
PKG_VERSION:=3.25
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/NetworkBlockDevice/nbd/releases/download/$(PKG_NAME)-$(PKG_VERSION)
PKG_HASH:=f5c8fd0fcb57b1c926594d0e57f356432ee08678bef1d40d088f0830f0cbdd0a
PKG_LICENSE:=GPL-2.0-or-later
PKG_MAINTAINER:=Marcin Jurkowski <marcin1j@gmail.com>
PKG_CPE_ID:=cpe:/a:network_block_device_project:network_block_device

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

# -liconv due to glib2, to be revisited later
include $(INCLUDE_DIR)/nls.mk

define Package/nbd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Network Block Device utilities
  URL:=https://nbd.sourceforge.io
  DEPENDS:=+kmod-nbd
endef

define Package/nbd/description
  This package contains the network block device client.
endef

define Package/nbd-server
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Network Block Device Server
  URL:=https://nbd.sourceforge.io
  DEPENDS:=+glib2
endef

define Package/nbd-server/description
  This package contains the network block device server.
endef

CONFIGURE_ARGS += \
	--without-gnutls \
	--without-libnl \
	--enable-syslog

TARGET_CFLAGS += -DNODAEMON

define Package/nbd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/nbd-client $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/nbd-client.conf $(1)/etc/config/nbd-client
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nbd-client.init $(1)/etc/init.d/nbd-client
endef

define Package/nbd/conffiles
/etc/config/nbd-client
endef

$(eval $(call BuildPackage,nbd))

define Package/nbd-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nbd-server $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/nbd-server.conf $(1)/etc/config/nbd-server
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nbd-server.init $(1)/etc/init.d/nbd-server
endef

define Package/nbd-server/conffiles
/etc/config/nbd-server
/etc/nbd-server/conf.d
/etc/nbd-server/allow
endef

$(eval $(call BuildPackage,nbd-server))
