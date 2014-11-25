#
# Copyright (C) 2008-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=freetype
PKG_VERSION:=17.2.11
PKG_RELEASE:=1

PKG_SOURCE_VERSION:=02b8e7e8d751605b133568b86fbb5dff48b6b5a5
PKG_SOURCE:=$(PKG_NAME)2-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_URL:=http://git.savannah.gnu.org/cgit/freetype/freetype2.git/snapshot/
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)2-$(PKG_SOURCE_VERSION)/
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)2-$(PKG_SOURCE_VERSION)/
PKG_MD5SUM:=ab713eef5f9a585f9f299eec3908b58d

PKG_LICENSE:=FTL GPL-2.0 MIT ZLIB
PKG_LICENSE_FILES:=docs/LICENSE.TXT docs/FTL.TXT docs/GPLv2.txt src/bdf/README src/pcf/README src/gzip/zlib.h
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

include $(INCLUDE_DIR)/autotools.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/libfreetype
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A free, high quality and portable font engine
  DEPENDS:=+zlib +libbz2
  URL:=http://www.freetype.org
endef

define Package/libfreetype/description
	The FreeType project is a team of volunteers who develop free,
	portable and high-quality software solutions for digital photography.
	They specifically target embedded systems and focus on bringing small,
	efficient and ubiquitous products.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--with-bzip2 \
	--with-zlib \
	--with-png=no \
	--with-harfbuzz=no

HOST_CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--with-bzip2 \
	--with-zlib \
	--with-png=no \
	--with-harfbuzz=no

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		./autogen.sh; \
	)
	$(call Build/Configure/Default)
endef

define Host/Configure
	(cd $(HOST_BUILD_DIR); \
		./autogen.sh; \
	)
	$(call Host/Configure/Default)
endef

define Build/Compile	
	$(MAKE) -C $(PKG_BUILD_DIR) DESTDIR=$(PKG_INSTALL_DIR) all install
endef

define Build/InstallDev
	$(INSTALL_DIR) \
		$(2)/bin \
		$(1)/usr/include \
		$(1)/usr/lib \
		$(1)/usr/lib/pkgconfig
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/freetype-config $(2)/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/freetype2 $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfreetype.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/freetype2.pc $(1)/usr/lib/pkgconfig/
	$(SED) \
		's,^\(prefix\|exec_prefix\)=.*,\1="$(STAGING_DIR)/usr",g' \
		$(2)/bin/freetype-config
endef

define Package/libfreetype/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfreetype.so.* $(1)/usr/lib/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libfreetype))
