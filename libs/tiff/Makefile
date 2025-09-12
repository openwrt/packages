#
# Copyright (C) 2006-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tiff
PKG_VERSION:=4.7.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://download.osgeo.org/libtiff
PKG_HASH:=67160e3457365ab96c5b3286a0903aa6e78bdc44c4bc737d2e486bcecb6ba976

PKG_MAINTAINER:=Jiri Slachta <jiri@slachta.eu>
PKG_LICENSE:=libtiff
PKG_LICENSE_FILES:=LICENSE.md
PKG_CPE_ID:=cpe:/a:libtiff:libtiff

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/tiff/Default
  TITLE:=TIFF
  URL:=http://simplesystems.org/libtiff/
endef

define Package/libtiff
$(call Package/tiff/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= library
  DEPENDS:=+zlib +libjpeg
  ABI_VERSION:=6
endef

define Package/tiff-utils
$(call Package/tiff/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Image Manipulation
  TITLE+= utilities
  DEPENDS:=+libtiff
endef

CMAKE_OPTIONS += \
	-Dld-version-script=OFF \
	-Dold-jpeg=OFF \
	-Djbig=OFF \
	-Dlzma=OFF \
	-Dzstd=OFF \
	-Dwebp=OFF \
	-Djpeg12=OFF \
	-Dcxx=OFF \
	-Dlibdeflate=OFF

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/libtiff-4.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/libtiff-4.pc
endef

define Package/libtiff/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtiff.so.$(ABI_VERSION)* $(1)/usr/lib
endef

define Package/tiff-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libtiff))
$(eval $(call BuildPackage,tiff-utils))
