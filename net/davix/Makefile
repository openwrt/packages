#
# Copyright (C) 2007-2020 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=davix
PKG_VERSION:=0.7.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/cern-fts/davix/releases/download/R_0_7_5/
PKG_HASH:=d920ca976846875d83af4dc50c99280bb3741fcf8351d5733453e70fa5fe6fc8

PKG_BUILD_PARALLEL:=1

PKG_MAINTAINER:=Yury Martynov <email@linxon.ru>
PKG_LICENSE:=LGPL-2.1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/davix
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libxml2 +libuuid +libopenssl
  TITLE:=High-performance file management over WebDAV/HTTP
  URL:=https://dmc.web.cern.ch/projects/davix
endef

TARGET_LDFLAGS+= \
	-static-libstdc++

CMAKE_OPTIONS += \
	-DDAVIX_TESTS=OFF \
	-DBENCH_TESTS=OFF \
	-DENABLE_TOOLS=ON \
	-DENABLE_TCP_NODELAY=ON

CMAKE_OPTIONS += $(if $(CONFIG_IPV6),-DENABLE_IPV6=ON,-DENABLE_IPV6=OFF)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdavix*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/davix.pc $(1)/usr/lib/pkgconfig/
endef

define Package/davix/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME)-* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdavix*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,davix))
