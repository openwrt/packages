include $(TOPDIR)/rules.mk

PKG_NAME:=yggdrasil-jumper
PKG_VERSION:=0.3.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-vendor.tar.zst
PKG_SOURCE_URL:=@OPENWRT
PKG_SOURCE_PROTO:=cargo-vendor-github
PKG_VENDOR_REPO:=one-d-wide/yggdrasil-jumper
PKG_VENDOR_TAG:=v$(PKG_VERSION)
PKG_VENDOR_HASH:=7f3e2021fe901ed866c6220d7ffdc0a0bc949ffb7c86fd3cd3783a594526d8fd
PKG_HASH:=16d347313dd5dd19706fbbb9c364ab41e2a0920e8b2fd406b31d137df7590874

PKG_MAINTAINER:=Remy D. Farley <one-d-wide@protonmail.com>
PKG_LICENSE:=LGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/rust-package.mk

define Package/yggdrasil-jumper
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Yggdrasil peer-to-peer firewall stun
  URL:=https://github.com/one-d-wide/yggdrasil-jumper
  DEPENDS:=$(RUST_PKG_DEPENDS) @!arc @IPV6 +kmod-tun
endef

define Package/yggdrasil-jumper/description
  Yggdrasil-Jumper is an independent project that aims to transparently reduce
  latency of a connection over Yggdrasil network, utilizing NAT traversal to
  bypass intermediary nodes. It periodically probes for active sessions and
  automatically establishes direct peerings over internet with remote nodes
  running Yggdrasil-Jumper without requiring any firewall configuration or
  port mapping.
endef

define Package/yggdrasil-jumper/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/yggdrasil-jumper $(1)/usr/sbin
endef

$(eval $(call RustBinPackage,yggdrasil-jumper))
$(eval $(call BuildPackage,yggdrasil-jumper))
