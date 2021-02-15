#
# Copyright (C) 2021 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmspack
PKG_VERSION:=0.10.1alpha
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.cabextract.org.uk/$(PKG_NAME)/
PKG_HASH:=bac862dee6e0fc10d92c70212441d9f8ad9b0222edc9a708c3ead4adb1b24a8e

PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING.LIB

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libmspack
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Compressors and decompressors for Microsoft formats
  DEPENDS:=@TARGET_x86
  URL:=https://github.com/kyz/libmspack
endef

define Package/libmspack/description
  The purpose of libmspack is to provide compressors and decompressors,
  archivers and dearchivers for Microsoft compression formats: CAB, CHM, WIM,
  LIT, HLP, KWAJ and SZDD. It is also designed to be easily embeddable,
  stable, robust and resource-efficient.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/mspack.h \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc \
		$(1)/usr/lib/pkgconfig

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib
endef

define Package/libmspack/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib
endef

$(eval $(call BuildPackage,libmspack))
