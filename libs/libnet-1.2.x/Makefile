#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libnet
PKG_VERSION:=1.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/libnet/libnet/releases/download/v$(PKG_VERSION)
PKG_HASH:=ad1e2dd9b500c58ee462acd839d0a0ea9a2b9248a1287840bc601e774fb6b28f

PKG_MAINTAINER:=Mislav Novakovic <mislav.novakovic@sartura.hr>
PKG_LICENSE:=GPL-2.0
PKG_CPE_ID:=cpe:/a:libnet_project:libnet

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libnet-1.2.x
 SECTION:=libs
 CATEGORY:=Libraries
 DEPENDS:=+libpcap
 TITLE:=Low-level packet creation library
endef

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--with-pic

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/libnet-config $(STAGING_DIR)/usr/bin
	$(INSTALL_DIR) $(2)/bin
	$(LN) ../../usr/bin/libnet-config $(2)/bin/

	$(INSTALL_DIR) $(STAGING_DIR)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libnet.h $(STAGING_DIR)/usr/include

	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/libnet
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libnet/*.h $(STAGING_DIR)/usr/include/libnet

	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/libnet
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libnet/libnet-*.h $(STAGING_DIR)/usr/include/libnet

	$(INSTALL_DIR) $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnet.{a,la,so*} $(STAGING_DIR)/usr/lib

	$(INSTALL_DIR) $(STAGING_DIR)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libnet.pc $(STAGING_DIR)/usr/lib/pkgconfig
endef

define Package/libnet-1.2.x/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnet.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libnet-1.2.x))
