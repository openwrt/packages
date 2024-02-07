#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libfastjson
PKG_VERSION:=1.2304.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://download.rsyslog.com/libfastjson
PKG_HASH:=ef30d1e57a18ec770f90056aaac77300270c6203bbe476f4181cc83a2d5dc80c

PKG_MAINTAINER:=Dov Murik <dmurik@us.ibm.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:rsyslog:libfastjson

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libfastjson
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A fast JSON library for C
  URL:=https://github.com/rsyslog/libfastjson
endef

define Package/libfastjson/description
  libfastjson - A fast JSON library for C
endef

TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/libfastjson/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfastjson.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libfastjson))
