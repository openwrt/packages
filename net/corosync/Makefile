# Copyright (C) 2025-2026 S Shaikh <sshaikh@hotmail.com>
# Copyright (C) 2026 Sven Kirmess <sven.kirmess@kzone.ch>

include $(TOPDIR)/rules.mk

PKG_NAME:=corosync
PKG_VERSION:=3.1.10
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/corosync/corosync/releases/download/v$(PKG_VERSION)/
PKG_HASH:=be361c827f99b215b3bd3fa2fb071c03dac6831c2a351963d938caef62604bc8
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_BUILD_DEPENDS:=libqb kronosnet

PKG_MAINTAINER:=S Shaikh <sshaikh@hotmail.com>, Sven Kirmess <sven.kirmess@kzone.ch>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/libcorosync
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Corosync cluster libraries
  URL:=https://corosync.github.io/corosync/
  DEPENDS:=+kronosnet +libqb
endef

define Package/libcorosync/description
  Shared libraries for Corosync cluster engine, including libcorosync_common,
  libcfg, libcmap, libcpg, libquorum, libsam, and libvotequorum.
endef

define Package/corosync
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Corosync cluster engine
  URL:=https://corosync.github.io/corosync/
  DEPENDS:=+libcorosync
endef

define Package/corosync/description
  Corosync cluster engine daemon and management tools, providing reliable
  messaging, membership, and quorum for high-availability clusters.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/corosync
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/corosync/* $(1)/usr/include/corosync/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
endef

define Package/libcorosync/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so.* $(1)/usr/lib/
endef

define Package/corosync/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/corosync $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/corosync-cfgtool $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/corosync-cmapctl $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/corosync-cpgtool $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/corosync-keygen $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/corosync-notifyd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/corosync-quorumtool $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,libcorosync))
$(eval $(call BuildPackage,corosync))
