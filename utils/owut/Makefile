#
# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2024 Eric Fahlgren <ericfahlgren@gmail.com>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=owut
PKG_SOURCE_DATE:=2025-09-27
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=f049043ed7219e7736e6e9d1e6cf4cc6b444945f
PKG_SOURCE_URL:=https://github.com/efahl/owut.git
PKG_MIRROR_HASH:=1b96ee209d15db7d2c58a1a626b9c94f64dec68595eb50ac6be9958014957333

PKG_MAINTAINER:=Eric Fahlgren <ericfahlgren@gmail.com>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/owut
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=owut - an OpenWrt Upgrade Tool
  URL:=http://github.com/efahl/owut
  DEPENDS:=+attendedsysupgrade-common \
    +rpcd-mod-file \
    +ucode +ucode-mod-fs +ucode-mod-ubus \
    +ucode-mod-uci +ucode-mod-uclient +ucode-mod-uloop
  PKGARCH:=all
endef

define Package/owut/description
  The OpenWrt Upgrade Tool (owut) is a command line program that
  checks for new packages, package build breakages, generates
  sysupgrade images containing installed packages and installs
  images.  It is written in ucode for easy end-user customization.

  Documentation is available at
  https://openwrt.org/docs/guide-user/installation/sysupgrade.owut
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/owut/conffiles
/etc/owut.d/
endef

define Package/owut/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/files/owut.defaults $(1)/etc/uci-defaults/51-attendedsysupgrade-owut

	$(INSTALL_DIR) $(1)/etc/owut.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/pre-install.sh $(1)/etc/owut.d/pre-install.sh

	$(INSTALL_DIR) $(1)/usr/share/ucode/utils
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/argparse.uc $(1)/usr/share/ucode/utils

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/owut $(1)/usr/bin

	sed -i -e "s/%%VERSION%%/$(PKG_VERSION)-r$(PKG_RELEASE)/" $(1)/usr/bin/owut
	sed -i -e "s/%%VERSION%%/$(PKG_VERSION)-r$(PKG_RELEASE)/" $(1)/usr/share/ucode/utils/argparse.uc
endef

$(eval $(call BuildPackage,owut))
