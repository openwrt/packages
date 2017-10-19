#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libgmime
PKG_VERSION:=2.6.23
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://git.gnome.org/browse/gmime/snapshot/
PKG_SOURCE:=gmime-$(PKG_VERSION).tar.gz
PKG_HASH:=87fa19d273b179f74c4608d68dd13a1d28098075e68fe9c25329b279f5c5d6bd

PKG_MAINTAINER:=Marko Ratkaj <marko.ratkaj@sartura.hr>
PKG_LICENSE:=LGPL-2.1

PKG_BUILD_DIR:=$(BUILD_DIR)/gmime-$(PKG_VERSION)
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libgmime
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GMime is a powerful MIME utility library
  URL:=https://developer.gnome.org/gmime/
  DEPENDS:= +glib2 +libpthread
endef

define Package/libgmime/description
  GMime is a powerful MIME (Multipurpose Internet Mail Extension)
  utility library. It is meant for creating, editing, and parsing
  MIME messages and structures.
endef

CONFIGURE_ARGS += \
	--disable-glibtest \
	--with-libiconv=no \
	--enable-vala=no \
	--disable-mono \
	--enable-smime

CONFIGURE_VARS += \
	ac_cv_have_iconv_detect_h=yes \
	ac_cv_path_GPGME_CONFIG="no"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/include/gmime
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/gmime-2.6/gmime/* \
		$(1)/usr/include/gmime/
endef

define Package/libgmime/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgmime-2.6.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgmime))
