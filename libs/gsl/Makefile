#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gsl
PKG_VERSION:=2.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/gsl
PKG_HASH:=562500b789cd599b3a4f88547a7a3280538ab2ff4939504c8b4ac4ca25feadfb

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Eduardo Abinader <eduardoabinader@gmail.com>

PKG_FIXUP:=libtool
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libgsl
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=@!TARGET_avr32
  TITLE:=GNU Scientific Library
  URL:=http://www.gnu.org/software/gsl/
endef

define Package/libgsl/description
	The library provides a wide range of mathematical routines such as
	random number generators, special functions and least-squares fitting.
	There are over 1000 functions in total with an extensive test suite.
endef

TARGET_CFLAGS += $(FPIC)

define Package/libgsl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgsl.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgslcblas.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/gsl $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gsl/*.h $(1)/usr/include/gsl
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgsl.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgslcblas.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgsl))
