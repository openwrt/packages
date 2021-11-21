#
# Copyright (C) 2021 David Bauer <mail@david-bauer.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clocate
PKG_SOURCE_DATE:=2021-11-09
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/blocktrron/clocate.git
PKG_SOURCE_VERSION:=4a4c0c0cb53fc3df2891d649eb457efdee843572
PKG_MIRROR_HASH:=8eef756ea5e951097eea53feb243a317612f88c2628c9417f4b28a28a3b4686c

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
