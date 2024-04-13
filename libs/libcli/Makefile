# Copyright (C) 2022 Martin Blumenstingl <martin.blumenstingl@googlemail.com>
#
# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=libcli

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/dparrish/libcli.git
PKG_SOURCE_DATE:=2022-07-06
PKG_SOURCE_VERSION:=V1.10.7
PKG_MIRROR_HASH:=ee686c27f80317680d151423b621ed0643992e28f6b5be2caca28318a25fe98c

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
  DEPENDS:=+libc
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
