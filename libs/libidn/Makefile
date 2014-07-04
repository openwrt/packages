#
# Copyright (C) 2009-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libidn
PKG_VERSION:=1.18
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/libidn
PKG_MD5SUM:=66f115347439f56386f37a3ad92c1da2

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=GNUmakefile aclocal.m4

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libidn
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Stringprep, Punycode and IDNA implementation
  URL:=http://www.gnu.org/software/libidn/
endef

define Package/libidn/description
  GNU Libidn is a fully documented implementation of the Stringprep,
  Punycode and IDNA specifications. Libidn's purpose is to encode and
  decode internationalized domain names.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \

MAKE_FLAGS += \
	CC="$(TARGET_CC)" \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libidn.{a,so*} $(1)/usr/lib/
endef

define Package/libidn/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libidn.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libidn))
