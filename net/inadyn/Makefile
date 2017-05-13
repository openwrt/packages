#
# Copyright (C) 2017 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=inadyn
PKG_VERSION=2017-02-02
PKG_RELEASE:=1
PKG_MAINTAINER:=Daniel Engberg <daniel.engberg.lists@pyret.net>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/troglobit/inadyn
PKG_SOURCE_SUBDIR=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=3b9ae1c22f96194232cc86ded33af9e0a1602af2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=9db6cd8d2b421d8bc61d4ae60c8215a86d73657746a1b06d79f4fbfd79734f6e

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
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/examples/dyndns.conf $(1)/etc/inadyn.conf
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/inadyn $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,inadyn))
