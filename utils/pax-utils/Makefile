#
# Copyright (C) 2019 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pax-utils
PKG_VERSION:=1.3.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://dev.gentoo.org/~sam/distfiles/app-misc/pax-utils/
PKG_HASH:=108362d29668d25cf7b0cadc63b15a4c1cfc0dbc71adc151b33c5fe7dece939a

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:gentoo:pax-utils

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/pax-utils
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=ELF utils for security relevant property checking
  URL:=https://wiki.gentoo.org/wiki/Hardened/PaX_Utilities
  DEPENDS:=+libcap
endef

define Package/pax-utils/description
  A suite of ELF tools to aid auditing systems. Contains various
  ELF related utils for ELF32, ELF64 binaries useful for displaying
  PaX and security info on a large groups of binary files.
endef

define Package/pax-utils/config
  source "$(SOURCE)/Config.in"
endef

MESON_ARGS += \
	-Dlddtree_implementation=sh \
	-Duse_seccomp=$(if $(CONFIG_PAX_UTILS_SECCOMP),true,false)

define Package/pax-utils/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{dumpelf,lddtree,pspax,scanelf,scanmacho,symtree} $(1)/usr/bin/
endef

$(eval $(call BuildPackage,pax-utils))
