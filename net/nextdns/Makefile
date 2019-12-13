#
# Copyright (C) 2019 NextDNS Inc
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nextdns
PKG_VERSION:=1.3.1
PKG_RELEASE:=4

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/nextdns/nextdns.git
PKG_MIRROR_HASH:=bb3b1901ba4d65b91f69487c59fbae89654fc22d368d37f3640c6eb457a2a0a1

PKG_MAINTAINER:=Olivier Poitrey <rs@nextdns.io>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/nextdns/nextdns
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=main.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/nextdns
  SECTION:=net
  CATEGORY:=Network
  TITLE:=NextDNS DNS over HTTPS Proxy
  URL:=https://github.com/nextdns/nextdns
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/nextdns/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nextdns $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nextdns.init $(1)/etc/init.d/nextdns

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/nextdns.config $(1)/etc/config/nextdns
endef

define Package/nextdns/description
  Official NextDNS DNS over HTTPS Proxy.
endef

define Package/golang-github-nextdns-nextdns-dev
$(call Package/nextdns)
$(call GoPackage/GoSubMenu)
  TITLE+= (source files)
  PKGARCH:=all
endef

define Package/golang-github-nextdns-nextdns-dev/description
$(call Package/nextdns/description)

  This package provides the source files for the client/bridge program.
endef

$(eval $(call GoBinPackage,nextdns))
$(eval $(call BuildPackage,nextdns))
$(eval $(call GoSrcPackage,golang-github-nextdns-nextdns-dev))
$(eval $(call BuildPackage,golang-github-nextdns-nextdns-dev))
