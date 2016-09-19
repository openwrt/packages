#
# Copyright (C) 2011-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=engine_pkcs11
PKG_VERSION:=0.2.2
PKG_RELEASE:=1
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPL-2.1+

PKG_SOURCE_URL:=https://github.com/OpenSC/engine_pkcs11/releases/download/$(PKG_NAME)-$(PKG_VERSION)/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_CONFIG_DEPENDS:=CONFIG_OPENSSL_ENGINE

include $(INCLUDE_DIR)/package.mk

PKG_FIXUP:=libtool
PKG_INSTALL:=1

CONFIGURE_ARGS += --with-enginesdir=/usr/lib/engines

define Package/engine_pkcs11
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=PKCS#11 OpenSSL engine
  URL:=https://www.opensc-project.org/opensc/wiki/
  DEPENDS:=+libopenssl +libp11
endef

define Package/engine_pkcs11/description
  engine_pkcs11 is an implementation of OpenSSL engine interface.
endef

define Package/engine_pkcs11/install
	$(INSTALL_DIR) $(1)/usr/lib/engines
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/engines/libpkcs11.so $(1)/usr/lib/engines/
endef

$(eval $(call BuildPackage,engine_pkcs11))
