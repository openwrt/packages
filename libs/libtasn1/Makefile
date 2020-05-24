#
# Copyright (C) 2005-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtasn1
PKG_VERSION:=4.15.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/$(PKG_NAME)
PKG_HASH:=dd77509fe8f5304deafbca654dc7f0ea57f5841f41ba530cff9a5bf71382739e

PKG_MAINTAINER:=Nikos Mavrogiannopoulos <n.mavrogiannopoulos@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING.LIB
PKG_CPE_ID:=cpe:/a:gnu:libtasn1

#PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/libtasn1
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=An ASN.1 and DER structures manipulation library
  URL:=https://www.gnu.org/software/libtasn1/
endef

define Package/libtasn1/description
 This is a library for Abstract Syntax Notation One (ASN.1) and
 Distinguish Encoding Rules (DER) manipulation.
endef

HOST_CFLAGS += -std=gnu99
TARGET_CFLAGS += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections

CONFIGURE_ARGS += \
	--disable-doc \
	--disable-gcc-warnings \
	--disable-ld-version-script \
	--disable-valgrind-tests

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libtasn1.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtasn1.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libtasn1*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libtasn1/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtasn1.so.* $(1)/usr/lib/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libtasn1))
