#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=picocom
PKG_VERSION:=1.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://picocom.googlecode.com/files
PKG_MD5SUM:=8eaba1d31407e8408674d6e57af447ef

PKG_MAINTAINER:=Steven Barth <cyrus@openwrt.org>
PKG_LICENSE:=GPL-2.0+

include $(INCLUDE_DIR)/package.mk

define Package/picocom
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=A minimal dumb-terminal emulation program
  URL:=http://code.google.com/p/picocom/
  SUBMENU:=Terminal
endef

define Package/picocom/description
 minimal dumb-terminal emulation program
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		picocom
endef

define Package/picocom/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/picocom $(1)/usr/bin/
endef

$(eval $(call BuildPackage,picocom))
