# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato

include $(TOPDIR)/rules.mk

PKG_NAME:=libnvme
PKG_VERSION:=1.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/linux-nvme/libnvme/archive/refs/tags/v$(PKG_VERSION)
PKG_HASH:=53791f2e75773ba95449fc98a3b8b444d984624322ec6980049fd4eb289123d5

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libnvme
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=C Library for NVM Express on Linux
  URL:=https://github.com/linux-nvme/libnvme
  DEPENDS:=+libjson-c +liburing
endef

define Package/libnvme/description
  This is the libnvme development C library. libnvme provides type
  definitions for NVMe specification structures, enumerations, and
  bit fields, helper functions to construct, dispatch, and decode
  commands and payloads, and utilities to connect, scan, and manage
  nvme devices on a Linux system.
endef

MESON_ARGS += \
	-Dopenssl=disabled -Dpython=disabled -Dkeyutils=disabled -Dtests=false

define Package/libnvme/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnvme*.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/nvme
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/nvme/*.h $(1)/usr/include/nvme
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnvme*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libnvme*.pc $(1)/usr/lib/pkgconfig/
endef

$(eval $(call BuildPackage,libnvme))
