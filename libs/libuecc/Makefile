#
# Copyright (C) 2012-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libuecc
PKG_VERSION:=6
PKG_RELEASE:=1

PKG_MAINTAINER:=Matthias Schiffer <mschiffer@universe-factory.net>
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://projects.universe-factory.net/attachments/download/83
PKG_MD5SUM:=cba68339ff46482ec4090303de18fff4

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=COPYRIGHT

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libuecc
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Very small Elliptic Curve Cryptography library
  URL:=http://git.universe-factory.net/libuecc/
endef

TARGET_CFLAGS += -ffunction-sections -fdata-sections

CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE:String="MINSIZEREL"


define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libuecc-$(PKG_VERSION) $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libuecc.a $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libuecc.pc $(1)/usr/lib/pkgconfig/
endef

$(eval $(call BuildPackage,libuecc))
