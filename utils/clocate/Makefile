#
# Copyright (C) 2021 David Bauer <mail@david-bauer.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clocate
PKG_SOURCE_DATE:=2021-07-07
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/blocktrron/clocate.git
PKG_SOURCE_VERSION:=ef531687c16bab959f61dff3755148ac9a0c1464
PKG_MIRROR_HASH:=1fde4052113a52c018476062a5fad656673b89be95a469fed2d35649a7f1bce3

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
