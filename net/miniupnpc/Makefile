#
# Copyright (C) 2010-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=miniupnpc
PKG_VERSION:=2.0.20180203
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://miniupnp.tuxfamily.org/files
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=90dda8c7563ca6cd4a83e23b3c66dbbea89603a1675bfdb852897c2c9cc220b7
PKG_MAINTAINER:=Steven Barth <cyrus@openwrt.org>

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/miniupnpc/Default
  TITLE:=Lightweight UPnP
  URL:=http://miniupnp.tuxfamily.org/
endef

define Package/miniupnpc
  $(call Package/miniupnpc/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Firewall
  TITLE+= client
  DEPENDS:=+libminiupnpc
endef

define Package/libminiupnpc
  $(call Package/miniupnpc/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= library
endef

CMAKE_OPTIONS+=-DCMAKE_BUILD_TYPE=MinSizeRel -DUPNPC_BUILD_TESTS=FALSE

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/miniupnpc
	$(CP) $(PKG_INSTALL_DIR)/usr/include/miniupnpc/*.h $(1)/usr/include/miniupnpc/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{s*,a} $(1)/usr/lib/
endef

define Package/miniupnpc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/upnpc $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/listdevices $(1)/usr/bin/
endef

define Package/libminiupnpc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libminiupnpc.s* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,miniupnpc))
$(eval $(call BuildPackage,libminiupnpc))
