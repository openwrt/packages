#
# Copyright (C) 2020 CZ.NIC z.s.p.o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=checksec
PKG_VERSION:=3.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/slimm609/checksec.sh/archive/$(PKG_VERSION)
PKG_HASH:=cd3112fb02577726dd6945a11d9225d508ac0d59984d772fbbda5d9cf2d2c290

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE_FILES:=LICENSE.txt

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
