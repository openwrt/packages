#
# Copyright (C) 2006-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tiff
PKG_VERSION:=4.7.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://download.osgeo.org/libtiff
PKG_HASH:=f698d94f3103da8ca7438d84e0344e453fe0ba3b7486e04c5bf7a9a3fabe9b69

PKG_MAINTAINER:=Jiri Slachta <jiri@slachta.eu>
PKG_LICENSE:=libtiff
PKG_LICENSE_FILES:=LICENSE.md
PKG_CPE_ID:=cpe:/a:libtiff:libtiff

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/tiff/Default
  TITLE:=TIFF
  URL:=https://libtiff.gitlab.io/libtiff/
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
  DEPENDS:=+libtiff +libstdcpp
endef

CMAKE_HOST_OPTIONS += \
	-DCMAKE_REQUIRED_LIBRARIES="-lm" \
	-Dld-version-script=OFF \
	-Dold-jpeg=OFF \
	-Djbig=OFF \
	-Dlzma=OFF \
	-Dzstd=OFF \
	-Dwebp=OFF \
	-Djpeg12=OFF \
	-Dcxx=OFF \
	-Dlibdeflate=OFF

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

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libtiff))
$(eval $(call BuildPackage,tiff-utils))
