#
# Copyright (C) 2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tailscale
PKG_VERSION:=1.44.0
PKG_RELEASE:=1

PKG_SOURCE:=tailscale-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/tailscale/tailscale/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=dc230cf3ac290140e573268a6e8f17124752ef064c8d3a86765a9dbb6f1bd354

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/tailscale-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=\
	tailscale.com/cmd/tailscale \
	tailscale.com/cmd/tailscaled
GO_PKG_LDFLAGS:=-X 'tailscale.com/version.longStamp=$(PKG_VERSION)-$(PKG_RELEASE) (OpenWrt)'
GO_PKG_LDFLAGS_X:=tailscale.com/version.shortStamp=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/tailscale/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=Zero config VPN
  URL:=https://tailscale.com
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/tailscaled
  $(call Package/tailscale/Default)
  TITLE+= (daemon)
  DEPENDS+= +ca-bundle +kmod-tun
endef

define Package/tailscale
  $(call Package/tailscale/Default)
  TITLE+= (utility)
  DEPENDS+= +tailscaled
endef

define Package/tailscale/description
  It creates a secure network between your servers, computers,
  and cloud instances. Even when separated by firewalls or subnets.
endef

Package/tailscaled/description:=$(Package/tailscale/description)

define Package/tailscaled/conffiles
/etc/config/tailscale
/etc/tailscale/tailscaled.state
endef

GO_IPTABLES_VERSION:=0.6.0
GO_IPTABLES_FILE:=$(PKG_NAME)-go-iptables-$(GO_IPTABLES_VERSION).tar.gz

define Download/go-iptables
  URL:=https://codeload.github.com/coreos/go-iptables/tar.gz/v$(GO_IPTABLES_VERSION)?
  URL_FILE:=$(GO_IPTABLES_FILE)
  FILE:=$(GO_IPTABLES_FILE)
  HASH:=a784cc17fcb17879f073eae47bc4c2e899f59f6906dac5a0aa7a9cc9f95ea66d
endef

define Build/Prepare
	$(PKG_UNPACK)
	[ ! -d ./src/ ] || $(CP) ./src/. $(PKG_BUILD_DIR)
	$(eval $(call Download,go-iptables))
	( \
		mkdir -p $(PKG_BUILD_DIR)/patched/ ; \
		gzip -dc $(DL_DIR)/$(GO_IPTABLES_FILE) | $(HOST_TAR) -C $(PKG_BUILD_DIR)/patched $(TAR_OPTIONS) ; \
		mv $(PKG_BUILD_DIR)/patched/go-iptables-$(GO_IPTABLES_VERSION) $(PKG_BUILD_DIR)/patched/go-iptables ; \
	)
	$(Build/Patch)
endef

define Package/tailscale/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/tailscale $(1)/usr/sbin
endef

define Package/tailscaled/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/tailscaled $(1)/usr/sbin
	$(INSTALL_BIN) ./files//tailscale.init $(1)/etc/init.d/tailscale
	$(INSTALL_DATA) ./files//tailscale.conf $(1)/etc/config/tailscale
endef

$(eval $(call BuildPackage,tailscale))
$(eval $(call BuildPackage,tailscaled))
