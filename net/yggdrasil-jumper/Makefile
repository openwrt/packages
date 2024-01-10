include $(TOPDIR)/rules.mk

PKG_NAME:=yggdrasil-jumper
PKG_VERSION:=0.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/one-d-wide/yggdrasil-jumper/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=d0fd59e9f7a110094c9189b49b812fb0014c6c45535b4d30effd7cf602961454

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
  Yggdrasil Jumper is independent project that aims to transparently reduce latency of
  a connection over Yggdrasil network, utilizing NAT traversal to bypass intermediary
  nodes. It periodically probes for active sessions and automatically establishes direct
  peerings over internet with remote nodes running Yggdrasil Jumper without requiring
  firewall or port configuration.
endef

define Package/yggdrasil-jumper/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/yggdrasil-jumper $(1)/usr/sbin
endef

$(eval $(call RustBinPackage,yggdrasil-jumper))
$(eval $(call BuildPackage,yggdrasil-jumper))
