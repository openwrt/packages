#
# Copyright (C) 2019-2021 Daniel Bermond
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=proxychains-ng
PKG_VERSION:=4.15
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rofl0r/proxychains-ng/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=c94edded38baa0447766f6e5d0ec1963bb27c7b55b2a78b305d6f58e171388f8

PKG_MAINTAINER:=Daniel Bermond <dbermond@archlinux.org>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/proxychains-ng
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Redirect TCP traffic to a HTTP or SOCKS proxy
  URL:=https://github.com/rofl0r/proxychains/
endef

define Package/proxychains-ng/description
  A hook preloader that allows to redirect TCP traffic of
  existing dynamically linked programs through one or more
  SOCKS or HTTP proxies.
endef

define Build/Compile
	$(call Build/Compile/Default,all)
endef

define Build/Install
	$(call Build/Install/Default,install install-config)
endef

define Package/proxychains-ng/conffiles
/etc/proxychains.conf
endef

define Package/proxychains-ng/install
	# binary executable
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/proxychains4 $(1)/usr/bin/
	$(LN) proxychains4 $(1)/usr/bin/proxychains
	
	# library
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libproxychains4.so $(1)/usr/lib/
	
	# config
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/proxychains.conf $(1)/etc/
endef

$(eval $(call BuildPackage,proxychains-ng))
