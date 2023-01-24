#
# Copyright (C) 2021 David Bauer <mail@david-bauer.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clocate
PKG_SOURCE_DATE:=2023-01-20
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/blocktrron/clocate.git
PKG_SOURCE_VERSION:=510cc944e4d4c28b5cc30d9808ab14e80486b437
PKG_MIRROR_HASH:=f4bcb77df4fc163a0d9b3350088ba6692f718ba0a1d48fa968685e2fded79ab8

PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/clocate
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libcurl +libnl-tiny +libjson-c
  TITLE:=Determine device location using neighbouring WiFi networks
endef

define Package/clocate/description
	This program can locate a device by sending the nighbouring WiFI networks
	to a geolocation Provider. Currently supported providers are Mozilla and Google.
endef

define Package/clocate/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/clocate $(1)/sbin/clocate
endef

MAKE_FLAGS += LIBNL_TINY=1

$(eval $(call BuildPackage,clocate))
