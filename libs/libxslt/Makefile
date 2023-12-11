#
# Copyright (C) 2014 - 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libxslt
PKG_VERSION:=1.1.39
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/libxslt/$(basename $(PKG_VERSION))
PKG_HASH:=2a20ad621148339b0759c4d4e96719362dee64c9a096dbba625ba053846349f0

PKG_MAINTAINER:=Jiri Slachta <jiri@slachta.eu>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:xmlsoft:libxslt

HOST_BUILD_DEPENDS:=libxml2/host
CMAKE_BINARY_SUBDIR:=openwrt-build

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/nls.mk

define Package/libxslt
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libxml2 $(ICONV_DEPENDS)
  TITLE:=Gnome XSLT library
  URL:=http://xmlsoft.org/XSLT/
endef

define Package/libxslt/description
 A library for XML transformation using XSLT.
endef

define Package/libexslt
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libxslt
  TITLE:=Gnome XSLT library Extension
  URL:=http://xmlsoft.org/XSLT/EXSLT/
endef

define Package/libexslt/description
 An extension for XSLT.
endef

define Package/xsltproc
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libxslt +PACKAGE_xsltproc:libexslt
  TITLE:=Gnome XSLT xsltproc Utility
  URL:=http://xmlsoft.org/XSLT/
endef

define Package/xsltproc/description
 XSLT XML transformation utility.
endef

CMAKE_HOST_OPTIONS += \
	-DBUILD_SHARED_LIBS=OFF \
	-DLIBXSLT_WITH_DEBUGGER=OFF \
	-DLIBXSLT_WITH_CRYPTO=OFF \
	-DLIBXSLT_WITH_MEM_DEBUG=OFF \
	-DLIBXSLT_WITH_MODULES=OFF \
	-DLIBXSLT_WITH_PROFILER=OFF \
	-DLIBXSLT_WITH_PYTHON=OFF \
	-DLIBXSLT_WITH_TESTS=OFF \
	-DLIBXSLT_WITH_THREADS=ON \
	-DLIBXSLT_WITH_XSLT_DEBUG=OFF

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DLIBXSLT_WITH_DEBUGGER=OFF \
	-DLIBXSLT_WITH_CRYPTO=OFF \
	-DLIBXSLT_WITH_MEM_DEBUG=OFF \
	-DLIBXSLT_WITH_MODULES=OFF \
	-DLIBXSLT_WITH_PROFILER=ON \
	-DLIBXSLT_WITH_PYTHON=OFF \
	-DLIBXSLT_WITH_TESTS=OFF \
	-DLIBXSLT_WITH_THREADS=ON \
	-DLIBXSLT_WITH_XSLT_DEBUG=OFF

define Build/InstallDev/Xslt
	$(INSTALL_DIR) $(1)/usr/bin $(2)/bin $(1)/usr/include/libxslt \
		$(1)/usr/include/libexslt $(1)/usr/lib \
		$(1)/usr/lib/pkgconfig

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/xslt-config \
		$(2)/bin/

	$(LN) $(STAGING_DIR)/host/bin/xslt-config $(1)/usr/bin/xslt-config

	$(SED) \
		's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' \
		$(2)/bin/xslt-config

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/libxslt/* \
		$(1)/usr/include/libxslt/

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxslt.so* \
		$(1)/usr/lib/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libxslt.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Build/InstallDev/Exslt
	$(INSTALL_DIR) $(1)/usr/include/libexslt $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/libexslt/* \
		$(1)/usr/include/libexslt/

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libexslt.so* \
		$(1)/usr/lib/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libexslt.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Build/InstallDev
	 $(if $(CONFIG_PACKAGE_libxslt),$(call Build/InstallDev/Xslt,$(1),$(2)))
	 $(if $(CONFIG_PACKAGE_libexslt),$(call Build/InstallDev/Exslt,$(1),$(2)))
endef

define Package/libxslt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libxslt.so* \
		$(1)/usr/lib/
endef

define Package/libexslt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libexslt.so* \
		$(1)/usr/lib/
endef

define Package/xsltproc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/xsltproc \
		$(1)/usr/bin/
endef

$(eval $(call BuildPackage,libxslt))
$(eval $(call BuildPackage,libexslt))
$(eval $(call BuildPackage,xsltproc))
$(eval $(call HostBuild))
