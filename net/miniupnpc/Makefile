#
# Copyright (C) 2010-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=miniupnpc
PKG_VERSION:=2.2.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://miniupnp.tuxfamily.org/files
PKG_HASH:=ff56bec3e5a3aec41f4decb43cb0b925231d6ab4cdfd7a74caa5c7c1043c4ef0

PKG_MAINTAINER:=
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:miniupnp_project:miniupnp

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/miniupnpc/Default
  TITLE:=Lightweight UPnP
  URL:=https://miniupnp.tuxfamily.org
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

CMAKE_OPTIONS += -DUPNPC_BUILD_TESTS=OFF

TARGET_CFLAGS += $(FPIC)
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/miniupnpc/ $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.{a,so*} $(1)/usr/lib/
endef

define Package/miniupnpc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/upnpc-shared $(1)/usr/bin/upnpc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/listdevices $(1)/usr/bin/
endef

define Package/libminiupnpc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libminiupnpc.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,miniupnpc))
$(eval $(call BuildPackage,libminiupnpc))
