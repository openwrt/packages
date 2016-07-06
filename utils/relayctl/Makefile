# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=relayctl
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://download.sourceforge.net/project/relayctl/relayctl-$(PKG_VERSION)
PKG_MAINTAINER:=Heinrich Schuchardt <xypron.glpk@gmx.de>
PKG_MD5SUM:=24c848e0d705421dcd6accfffa31f704
PKG_LICENSE:=BSD

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/relayctl
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Simple command-line control of SainSmart USB relay boards
  URL:=https://github.com/darryln/relayctl
  DEPENDS:= +libftdi1 +udev
endef

define Package/relayctl/description
 Simple command-line control of SainSmart USB relay boards based on
 FTDI chips using bitbang mode.
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/libftdi1

define Package/relayctl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/$(PKG_NAME) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/lib/udev/rules.d/
	$(CP) $(PKG_BUILD_DIR)/examples/60-relayctl.rules $(1)/lib/udev/rules.d/
endef

$(eval $(call BuildPackage,relayctl))
