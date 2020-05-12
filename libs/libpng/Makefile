#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libpng
PKG_VERSION:=1.6.37
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@SF/libpng
PKG_HASH:=505e70834d35383537b6491e7ae8641f1a4bed1876dbfe361201fc80868d88ca

PKG_MAINTAINER:=Jo-Philipp Wich <jo@mein.io>
PKG_LICENSE:=Libpng GPL-2.0-or-later BSD-3-Clause
PKC_LICENSE_FILES:=LICENSE contrib/gregbook/COPYING contrib/gregbook/LICENSE
PKG_CPE_ID:=cpe:/a:libpng:libpng

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/libpng
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+zlib
  TITLE:=A PNG format files handling library
  URL:=http://www.libpng.org/pub/png/libpng.html
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	$(if $(findstring neon,$(CONFIG_CPU_TYPE))$(findstring aarch64,$(CONFIG_ARCH)), \
		--enable-hardware-optimizations=yes --enable-arm-neon=yes)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/libpng{,16}-config $(1)/usr/bin/
	$(SED) \
		's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' \
		$(1)/usr/bin/libpng{,16}-config
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/png{,conf,libconf}.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libpng16 $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpng16.{a,la,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpng.{a,la,so} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libpng{,16}.pc $(1)/usr/lib/pkgconfig/
	$(INSTALL_DIR) $(2)/bin
	for f in libpng{,16}-config; do \
		$(LN) ../../usr/bin/$$$$f $(2)/bin/ ; \
	done
endef

define Package/libpng/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpng16.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpng.so $(1)/usr/lib/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libpng))
