#
# Copyright (C) 2005-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=OpenSC
PKG_VERSION:=0.13.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/OpenSC/OpenSC/archive/
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MD5SUM:=92ed0041be8e5c53aa48c371b090b6cd

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/OpenSC
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=tools and libraries for smart cards
  URL:=https://github.com/OpenSC/OpenSC/wiki
  DEPENDS+= +libpcsclite +libopenssl +pcscd
endef

define Package/OpenSC/description
 OpenSC provides a set of libraries and utilities to work with smart cards.
 Its main focus is on cards that support cryptographic operations, and facilitate
 their use in security applications such as authentication, mail encryption and
 digital signatures. OpenSC implements the PKCS11 API so applications supporting
 this API (such as Mozilla Firefox and Thunderbird) can use it. On the card OpenSC
 implements the PKCS15 standard and aims to be compatible with every software/card
 that does so, too.
endef

CONFIGURE_ARGS += \
		--disable-assert \
		--enable-pcsc \
		--enable-sm \
		--disable-zlib \
		--with-pcsc-provider=libpcsclite.so.1

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopensc.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsmm-local.{a,so*} $(1)/usr/lib/
endef

define Package/OpenSC/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/opensc-tool $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/pkcs15-tool $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/pkcs15-init $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopensc.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/opensc-pkcs11.so $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsmm-local.so.* $(1)/usr/lib/
ifeq ($(CONFIG_PACKAGE_p11-kit),)
	$(INSTALL_DIR) $(1)/etc/p11-kit/modules/
	$(CP) \
		./files/opensc.module \
		$(1)/etc/p11-kit/modules/
endif
endef

$(eval $(call BuildPackage,OpenSC))
