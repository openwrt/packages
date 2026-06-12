# Copyright (C) 2025-2026 S Shaikh <sshaikh@hotmail.com>
# Copyright (C) 2026 Sven Kirmess <sven.kirmess@kzone.ch>

include $(TOPDIR)/rules.mk

PKG_NAME:=libqb
PKG_VERSION:=2.0.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/ClusterLabs/libqb/releases/download/v$(PKG_VERSION)/
PKG_HASH:=61a83753199c86a47a69f615778e81b56ac0a58d07751230444e76500b6b210b
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=S Shaikh <sshaikh@hotmail.com>, Sven Kirmess <sven.kirmess@kzone.ch>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/libqb
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=High performance client server reusable library
  URL:=https://github.com/ClusterLabs/libqb
endef

define Package/libqb/description
  libqb provides high-performance, reusable features for client/server
  architecture, including IPC, logging, and ringbuffer. Used by Corosync
  and other cluster software.
endef

CONFIGURE_ARGS += --disable-man

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/qb
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/qb/* $(1)/usr/include/qb
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
endef

define Package/libqb/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libqb))
