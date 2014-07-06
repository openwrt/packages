#
# Copyright (C) 2009-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libidn
PKG_VERSION:=1.28
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/libidn
PKG_MD5SUM:=43a6f14b16559e10a492acc65c4b0acc

PKG_LICENSE:=GPLv2 GPLv3 LGPLv2.1 LGPLv3 APACHEv2
PKG_LICENSE_FILES:=COPYING COPYINGv2 COPYINGv3 COPYING.LESSERv2 COPYING.LESSERv3 java/LICENSE-2.0.txt
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

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
