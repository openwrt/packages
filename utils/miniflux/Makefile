#
# Copyright (C) 2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=miniflux
PKG_VERSION:=2.0.33
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/miniflux/v2/tar.gz/${PKG_VERSION}?
PKG_HASH:=b61c9ddb62be8f1cc15a70a1c916d55f8ac47299df9c2323552eb275a36d2cc3

PKG_MAINTAINER:=Michal Vasilek <michal.vasilek@nic.cz>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/v2-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=miniflux.app
GO_PKG_LDFLAGS_X:=miniflux.app/version.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/miniflux
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Feed reader
  USERID:=miniflux=1120:miniflux=1120
  URL:=https://miniflux.app
  DEPENDS:=$(GO_ARCH_DEPENDS) +pgsql-server
endef

define Package/miniflux/description
  Miniflux is a small and simple feed reader.
endef

define Package/miniflux/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/miniflux.conf $(1)/etc/config/miniflux
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/miniflux.init $(1)/etc/init.d/miniflux
endef

define Package/miniflux/conffiles
/etc/config/miniflux
endef

$(eval $(call GoBinPackage,miniflux))
$(eval $(call BuildPackage,miniflux))
