#
# Copyright (C) 2006-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=minicom
PKG_VERSION:=2.8
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://salsa.debian.org/minicom-team/minicom/-/archive/$(PKG_VERSION)
PKG_HASH:=38cea30913a20349326ff3f1763ee1512b7b41601c24f065f365e18e9db0beba
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:minicom:minicom

include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/package.mk

define Package/minicom
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=$(ICONV_DEPENDS) $(INTL_DEPENDS) +libncurses
  TITLE:=Terminal emulation program
  URL:=https://salsa.debian.org/minicom-team/minicom
  SUBMENU:=Terminal
endef

define Package/minicom/conffiles
/etc/minirc.dfl
endef

define Package/minicom/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/$(PKG_NAME) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ascii-xfr $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,minicom))
