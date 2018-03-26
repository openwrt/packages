#
# Copyright (C) 2011-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=p11-kit
PKG_VERSION:=0.23.10
PKG_RELEASE:=1
PKG_MAINTAINER:=Nikos Mavrogiannopoulos <n.mavrogiannopoulos@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=f9212a3f225ef543e13fae9945527d66c0cbb67246320035dd94fab2bce5ae43
PKG_SOURCE_URL:=https://github.com/p11-glue/$(PKG_NAME)/releases/download/$(PKG_VERSION)

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/p11-kit
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A library that provides a way to load and enumerate PKCS11 modules.
  URL:=https://p11-glue.github.io/p11-glue/p11-kit.html
  DEPENDS:=+libtasn1 +libpthread
endef

define Package/p11-kit/description
  Provides a way to load and enumerate PKCS11 modules. Provides a
  standard configuration setup for installing PKCS11 modules in such a
  way that they are discoverable.
endef

CONFIGURE_ARGS+= \
	--without-libffi \
	--disable-trust-module

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/p11-kit-1/p11-kit/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/p11-kit-1/p11-kit/* $(1)/usr/include/p11-kit-1/p11-kit/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libp11-kit.so $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libp11-kit.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/p11-kit-1.pc $(1)/usr/lib/pkgconfig/p11-kit-1.pc
endef

define Package/p11-kit/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libp11-kit.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/p11-kit/modules/
ifneq ($(CONFIG_PACKAGE_libopensc),)
	$(CP) ./files/opensc.module $(1)/etc/p11-kit/modules/
endif
endef

$(eval $(call BuildPackage,p11-kit))
