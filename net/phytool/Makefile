#
# Copyright (C) 2025 Bootlin
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=phytool
PKG_VERSION:=2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/wkz/phytool/releases/download/v$(PKG_VERSION)/
PKG_HASH:=9901a14e8c6af02b7333c60b21ff81f50620e8326d54827185e5617ff9b11d21

PKG_MAINTAINER:=Thomas Richard <thomas.richard@bootlin.com>

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENCE

include $(INCLUDE_DIR)/package.mk

define Package/phytool
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Linux MDIO register access
  URL:=https://github.com/wkz/phytool.git
endef

define Package/phytool/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/phytool $(1)/usr/bin/
endef

$(eval $(call BuildPackage,phytool))
