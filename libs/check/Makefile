#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=check
PKG_VERSION:=0.9.14
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/check
PKG_MD5SUM:=38263d115d784c17aa3b959ce94be8b8

PKG_LICENSE:=LGPL-2.1+
PKG_LICENSE_FILES:=COPYING.LESSER
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/check
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Unit testing framework for C
  URL:=http://check.sourceforge.net/
  DEPENDS:= +libpthread +librt
endef

define Package/check/description
  Check features a simple interface for defining unit tests, putting little in
  the way of the developer. Tests are run in a separate address space, so Check
  can catch both assertion failures and code errors that cause segmentation
  faults or other signals. The output from unit tests can be used within source
  code editors and IDEs.
endef

TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/check*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcheck.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/check.pc $(1)/usr/lib/pkgconfig/
endef

define Package/check/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcheck.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,check))
