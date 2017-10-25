#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mutt
PKG_VERSION:=1.9.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=ftp://ftp.mutt.org/pub/mutt/ \
		https://bitbucket.org/mutt/mutt/downloads/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=749b83a96373c6e2101ebe8c4b9a651735e02c478edb750750a5146a15d91bb1

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=GPL
PKG_MAINTAINER:=Phil Eichinger <phil@zankapfel.net>

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/mutt
  SECTION:=mail
  CATEGORY:=Mail
  DEPENDS:=+libopenssl +libncursesw +zlib
  TITLE:=Console mail client
  URL:=http://www.mutt.org/
endef

define Package/mutt/description
	Mutt is a small but very powerful text-based mail client for Unix
	operating systems.
endef

CONFIGURE_ARGS += \
	--includedir=$(PKG_BUILD_DIR)/. \
	--oldincludedir=$(PKG_BUILD_DIR)/. \
	--enable-pop \
	--enable-imap \
	--with-ssl \
	--without-idn \
	--disable-doc

define Package/mutt/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mutt $(1)/usr/bin/
endef

$(eval $(call BuildPackage,mutt))
