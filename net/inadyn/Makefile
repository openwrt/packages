#
# Copyright (C) 2017 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=inadyn
PKG_VERSION=2.2
PKG_RELEASE:=1
PKG_MAINTAINER:=Daniel Engberg <daniel.engberg.lists@pyret.net>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/troglobit/inadyn/releases/download/v$(PKG_VERSION)
PKG_HASH:=27aed84a3d04591540b01ef91a5af4b02cbd0e0c20db36a2660453780bd645f6

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/inadyn
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+confuse +libopenssl +ca-certificates
  TITLE:=A Dynamic DNS client with SSL/TLS support
  URL:=https://github.com/troglobit/inadyn
  SUBMENU:=IP Addresses and Names
endef

define Package/inadyn/description
  Suitable for embedded systems, written in C.
endef

define Package/inadyn/conffiles
/etc/inadyn.conf
endef

CONFIGURE_ARGS += --enable-shared --disable-static --enable-openssl

define Package/inadyn/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/inadyn $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,inadyn))
