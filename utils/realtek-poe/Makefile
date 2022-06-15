## SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=realtek-poe
PKG_RELEASE:=$(AUTORELEASE)
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Martin Kennedy <hurricos@gmail.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Hurricos/realtek-poe.git
PKG_SOURCE_VERSION:=382c60e7549948399b4244f7149cf76eaf5f0a7d
PKG_MIRROR_HASH:=442a01521c9a056e137e010be492ed5be0a39c3b68a2fa0ca0f0dbb765d9c74c
CMAKE_SOURCE_SUBDIR:=src

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/realtek-poe
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Realtek PoE Switch Port daemon
  DEPENDS:=@TARGET_realtek +libubox +libubus +libuci
endef

define Package/realtek-poe/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/realtek-poe $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/init.d/poe $(1)/etc/init.d/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/files/etc/config/poe $(1)/etc/config/
endef

$(eval $(call BuildPackage,realtek-poe))
