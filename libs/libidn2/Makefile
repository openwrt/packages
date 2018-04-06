#
# Copyright (C) 2017-2018 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libidn2
PKG_VERSION:=2.0.4
PKG_RELEASE:=1
PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later LGPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING COPYINGv2 COPYING.LESSERv3

PKG_SOURCE_URL:=@GNU/libidn
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=644b6b03b285fb0ace02d241d59483d98bc462729d8bb3608d5cad5532f3d2f0

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/libidn2
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libunistring $(ICONV_DEPENDS) $(INTL_DEPENDS)
  TITLE:=International domain name library (IDNA2008, Punycode and TR46)
  URL:=https://www.gnu.org/software/libidn/#libidn2
endef

define Package/libidn2/description
  Libidn2 is a free software implementation of IDNA2008,
  Punycode and TR46 in the form a library. It contains
  functionality to convert internationalized domain
  names to and from ASCII Compatible Encoding (ACE),
  following the IDNA2008 and TR46 standards.
endef

CONFIGURE_ARGS = \
	--target=$(GNU_TARGET_NAME) \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_HOST_NAME) \
	--enable-shared \
	--enable-static \
	--disable-rpath \
	--disable-doc \
	--disable-gtk-doc \
	--prefix=/usr

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/idn2.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{la,so}* $(1)/usr/lib/
endef

define Package/libidn2/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libidn2))
