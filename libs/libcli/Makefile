# Copyright (C) 2022 Martin Blumenstingl <martin.blumenstingl@googlemail.com>
#
# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=libcli
PKG_VERSION:=1.10.7
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=V$(PKG_VERSION)
PKG_SOURCE_URL=https://github.com/dparrish/libcli
PKG_MIRROR_HASH:=a9842266ae80f78b838f71c98bbfeed6c7082fadedd2d9a301aedc3e47a88af7

PKG_MAINTAINER:=Martin Blumenstingl <martin.blumenstingl@googlemail.com>
PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libcli
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libcli
  URL:=https://dparrish.com/link/libcli
  DEPENDS:= +USE_GLIBC:libcrypt-compat
endef

define Package/libcli/description
  Libcli provides a shared library for including a Cisco-like
  command-line interface into other software.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		TESTS=0 \
		all install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/local/include/libcli.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libcli.so* $(1)/usr/lib/
endef

define Package/libcli/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libcli.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libcli))
