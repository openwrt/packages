# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2021 Martin Schneider <martschneider@google.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=dns-over-https
PKG_VERSION:=2.3.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/m13253/dns-over-https/tar.gz/v${PKG_VERSION}?
PKG_HASH:=887456b25396a0234ef351e474079198b5b81bccf63cc6eedefef9d2d81821f2

PKG_MAINTAINER:=Martin Schneider <martschneider@google.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/m13253/dns-over-https
GO_PKG_INSTALL_BIN_PATH:=/usr/sbin

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/dns-over-https
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Query DNS over HTTPS
  URL:=https://github.com/m13253/dns-over-https
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/dns-over-https/description
  Client and server software to query DNS over HTTPS, using Google DNS-over-HTTPS protocol and IETF DNS-over-HTTPS (RFC 8484).
endef

define Package/dns-over-https/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/etc/dns-over-https
	$(CP) $(PKG_BUILD_DIR)/doh-client/doh-client.conf $(1)/etc/dns-over-https/doh-client.conf
	$(CP) $(PKG_BUILD_DIR)/doh-server/doh-server.conf $(1)/etc/dns-over-https/doh-server.conf
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/doh-client.init $(1)/etc/init.d/doh-client
	$(INSTALL_BIN) ./files/doh-server.init $(1)/etc/init.d/doh-server
endef

$(eval $(call GoBinPackage,dns-over-https))
$(eval $(call BuildPackage,dns-over-https))
