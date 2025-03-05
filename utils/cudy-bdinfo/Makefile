#
# Copyright (C) 2023 David Bauer <mail@david-bauer.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cudy-bdinfo
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/blocktrron/cudy-bdinfo-decrypt.git
PKG_SOURCE_DATE:=2023-06-01
PKG_SOURCE_VERSION:=5a60308c0fff610c4698207387d7153aba5fd62b
PKG_MIRROR_HASH:=92fba88358cf150a3be7dd982b2fdf90b9a730de415c39af99b6ac70bc907b53

PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>
PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/cudy-bdinfo
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=@(TARGET_ramips||TARGET_mediatek) +libopenssl
  TITLE:=Tool for reading the bdinfo partition of Cudy routers
endef

define Package/cudy-bdinfo/description
This program can be used to obtain information stored on the
bdinfo parition found on routers from Shenzhen Cudy Technology.
endef

define Package/cudy-bdinfo/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cudy-bdinfo $(1)/usr/bin/cudy-bdinfo
endef


$(eval $(call BuildPackage,cudy-bdinfo))
