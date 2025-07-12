#
# Copyright (C) 2016-2019 Jason A. Donenfeld <Jason@zx2c4.com>
# Copyright (C) 2016 Baptiste Jonglez <openwrt@bitsofnetworks.org>
# Copyright (C) 2016-2017 Dan Luedtke <mail@danrl.com>
# Copyright (C) 2024 Iurii Egorov <ye@amnezia.org>
# Copyright (C) 2024 Stan Grishin <stangri@melmac.ca>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=amneziawg-tools

PKG_VERSION:=1.0.20250903
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/amnezia-vpn/amneziawg-tools/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=d729a6f54aafcd55b2cbb7324f09ca8f0d2536772970652bf822a271d0c907d7

PKG_MAINTAINER:=Gregory Gullin <garuwex@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_PATH:=src
MAKE_VARS+=PLATFORM=linux

define Package/amneziawg-tools
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=VPN
	URL:=https://amnezia.org/
	TITLE:=AmneziaWG userspace control program

	DEPENDS:= \
		+!BUSYBOX_CONFIG_IP:ip \
		+!BUSYBOX_CONFIG_FEATURE_IP_LINK:ip \
		+kmod-amneziawg
endef

define Package/amneziawg-tools/description
	AmneziaWG is a fork of WireGuard, inheriting the architectural  
	simplicity and high performance of the original implementation, but  
	eliminating the identifiable network signatures that make WireGuard  
	easily detectable by Deep Packet Inspection (DPI) systems.

	This package provides the userspace control program for AmneziaWG,
	`awg`, a netifd protocol helper, and a re-resolve watchdog script.
endef

define Package/amneziawg-tools/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/wg $(1)/usr/bin/awg
	$(INSTALL_BIN) ./files/amneziawg_watchdog $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/lib/netifd/proto/
	$(INSTALL_BIN) ./files/amneziawg.sh $(1)/lib/netifd/proto/
endef

$(eval $(call BuildPackage,amneziawg-tools))
