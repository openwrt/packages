## SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=realtek-poe
PKG_VERSION:=1.3.2
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-or-later
PKG_MAINTAINER:=Martin Kennedy <hurricos@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Hurricos/realtek-poe/archive/refs/tags/v$(PKG_VERSION)
PKG_HASH:=2bb14d1043849eeaa6e8a4387e10227cf427e729d169578ab18a38fd4421d363
CMAKE_SOURCE_SUBDIR:=src

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/realtek-poe
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Realtek PoE Switch Port daemon
  DEPENDS:=+libubox +libubus +libuci
  URL:=https://github.com/Hurricos/realtek-poe
endef

define Package/realtek-poe/description
	Power over Ethernet interface for Realtek switches.
	Supports enabling/disabling PoE supply on ports and monitoring PoE client
	 power usage as well as total switch power budget.
endef

define Package/realtek-poe/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/realtek-poe $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/init.d/poe $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/etc/uci-defaults/30-poe $(1)/etc/uci-defaults/30-poe
endef

$(eval $(call BuildPackage,realtek-poe))
