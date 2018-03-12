#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nbd
PKG_VERSION:=3.16.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/nbd
PKG_HASH:=422f62bdf6e6b973bd82083dc52b6577396fe00aa6607837ac464e476124155b
PKG_LICENSE:=GPL-2.0+
PKG_MAINTAINER:=Marcin Jurkowski <marcin1j@gmail.com>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

# -liconv due to glib2, to be revisited later
include $(INCLUDE_DIR)/nls.mk

PKG_BUILD_DEPENDS:=glib2 gettext

define Package/nbd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Network Block Device utilities
  URL:=http://nbd.sourceforge.net
  DEPENDS:=+kmod-nbd
endef

define Package/nbd/description
  This package contains the network block device client.
endef

define Package/nbd-server
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Network Block Device Server
  URL:=http://nbd.sourceforge.net
  DEPENDS:=+glib2
endef

define Package/nbd-server/description
  This package contains the network block device server.
endef

CONFIGURE_ARGS += \
	--disable-glibtest \
	--without-gnutls

TARGET_CFLAGS += --std=gnu99 -DNODAEMON

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
