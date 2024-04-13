## SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=realtek-poe
PKG_RELEASE:=2
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Martin Kennedy <hurricos@gmail.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Hurricos/realtek-poe.git
PKG_SOURCE_VERSION:=39c93d39dd10da77b4fe48bc1d6bdd3c5978f866
PKG_MIRROR_HASH:=eb10a6d204bd79ab5a2925f05a68a1a66e0b5402de5d304265858b87d3f7b027
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
