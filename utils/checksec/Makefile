#
# Copyright (C) 2020 CZ.NIC z.s.p.o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=checksec
PKG_VERSION:=3.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/slimm609/checksec.sh/archive/$(PKG_VERSION)
PKG_HASH:=3ea46986821070ed06fef5215b2a83a9076115a865da70874e19f214db2c8d83

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/checksec
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://github.com/slimm609/checksec.sh
  TITLE:=Utility to check PIE, RELRO, ASLR etc.
  DEPENDS:=+bash +file +binutils +procps-ng +procps-ng-sysctl +openssl-util +coreutils +coreutils-stat
endef

define Package/checksec/description
  Checksec is a bash script to check the properties
  of executables (like PIE, RELRO, PaX, Canaries, ASLR, Fortify Source).
endef

Build/Compile:=:
Build/Install:=:

define Package/checksec/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/checksec.bash $(1)/usr/bin/checksec
endef

$(eval $(call BuildPackage,checksec))
