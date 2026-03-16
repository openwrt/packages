include $(TOPDIR)/rules.mk

PKG_NAME:=yggdrasil-jumper
PKG_VERSION:=0.3.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/one-d-wide/yggdrasil-jumper/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=7f3e2021fe901ed866c6220d7ffdc0a0bc949ffb7c86fd3cd3783a594526d8fd

PKG_MAINTAINER:=Remy D. Farley <one-d-wide@protonmail.com>
PKG_LICENSE:=LGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/yggdrasil-jumper
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Yggdrasil peer-to-peer firewall stun
  URL:=https://github.com/one-d-wide/yggdrasil-jumper
  DEPENDS:=$(RUST_ARCH_DEPENDS) @!arc @IPV6 +kmod-tun
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
