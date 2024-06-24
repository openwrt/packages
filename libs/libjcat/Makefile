#
# Copyright (C) 2024 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libjcat
PKG_VERSION:=0.2.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/hughsie/libjcat/releases/download/$(PKG_VERSION)
PKG_HASH:=a6232aeca3c3fab6dbb3bed06ec3832088b49a4b278a7119558d72be60ce921f

PKG_MAINTAINER:=Lukas Voegl <lvoegl@tdt.de>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=glib2/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libjcat
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libjcat
  URL:=https://github.com/hughsie/libjcat
  DEPENDS:= \
	+glib2 \
	+json-glib \
	+LIBJCAT_GPG:libgpgme \
	+LIBJCAT_GPG:libgpg-error \
	+LIBJCAT_PKCS7:libgnutls \
	+LIBJCAT_ED25519:libgnutls \
	+LIBJCAT_ED25519:libnettle
endef

define Package/libjcat/description
  libjcat allows reading and writing gzip-compressed JSON catalog files,
  which can be used to store GPG, PKCS-7 and SHA-256 checksums for each file.
endef

define Package/libjcat/config
	source "$(SOURCE)/Config.in"
endef

MESON_ARGS += \
	-Db_lto=true \
	-Dgtkdoc=false \
	-Dintrospection=false \
	-Dvapi=false \
	-Dtests=false \
	-Dman=false \
	-Dcli=false \
	-Dgpg=$(if $(CONFIG_LIBJCAT_GPG),true,false) \
	-Dpkcs7=$(if $(CONFIG_LIBJCAT_PKCS7),true,false) \
	-Ded25519=$(if $(CONFIG_LIBJCAT_ED25519),true,false)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libjcat-1
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libjcat-1/jcat.h $(1)/usr/include/libjcat-1/jcat.h

	$(INSTALL_DIR) $(1)/usr/include/libjcat-1/libjcat
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libjcat-1/libjcat/*.h $(1)/usr/include/libjcat-1/libjcat

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjcat.so* $(1)/usr/lib

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/jcat.pc $(1)/usr/lib/pkgconfig
endef

define Package/libjcat/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjcat.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libjcat))
