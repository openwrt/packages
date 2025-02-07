#
# Copyright (C) 2024 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libxmlb
PKG_VERSION:=0.3.19
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/hughsie/libxmlb/releases/download/$(PKG_VERSION)
PKG_HASH:=0a3ec258b12dbf10e5fe840b2421c84137eb7cc1b09c3de6210f3f7d51733733

PKG_MAINTAINER:=Lukas Voegl <lvoegl@tdt.de>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=glib2/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libxmlb
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libxmlb
  URL:=https://github.com/hughsie/libxmlb
  DEPENDS:= \
	+glib2 \
	+LIBXMLB_LZMA:liblzma \
	+LIBXMLB_ZSTD:libzstd
endef

define Package/libxmlb/description
  Library to help create and query binary XML blobs.
endef

define Package/libxmlb/config
	source "$(SOURCE)/Config.in"
endef

MESON_ARGS += \
	-Db_lto=true \
	-Dgtkdoc=false \
	-Dintrospection=false \
	-Dtests=false \
	-Dcli=false \
	-Dstemmer=false \
	-Dlzma=$(if $(CONFIG_LIBXMLB_LZMA),enabled,disabled) \
	-Dzstd=$(if $(CONFIG_LIBXMLB_ZSTD),enabled,disabled)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libxmlb-2
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libxmlb-2/xmlb.h $(1)/usr/include/libxmlb-2

	$(INSTALL_DIR) $(1)/usr/include/libxmlb-2/libxmlb
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libxmlb-2/libxmlb/*.h $(1)/usr/include/libxmlb-2/libxmlb

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libxmlb.so* $(1)/usr/lib

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/xmlb.pc $(1)/usr/lib/pkgconfig
endef

define Package/libxmlb/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libxmlb.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libxmlb))
