#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmcrypt
PKG_VERSION:=2.5.8
PKG_RELEASE:=2

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=LGPLv2.1
PKG_LICENSE_FILES:=COPYING.LIB

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/mcrypt
PKG_MD5SUM:=c4f491dd411a09e9de3b8702ea6f73eb

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += $(FPIC)

define Package/libmcrypt
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Cryptographic library
  URL:=http://mcrypt.sourceforge.net/
endef

define Package/libmcrypt/description
	libmcrypt is a cryptographic library that conveniently brings
	together a variety of ciphers for convenient use.
endef

define Build/Configure
	$(call Build/Configure/Default, \
		--enable-shared \
		--enable-static \
	)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmcrypt.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/libmcrypt-config $(1)/usr/bin/
	$(SED) 's,-I$$$${prefix}/include,,g' $(1)/usr/bin/libmcrypt-config
	$(SED) 's,-L$$$${exec_prefix}/lib,,g' $(1)/usr/bin/libmcrypt-config
endef

define Package/libmcrypt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmcrypt.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libmcrypt))
