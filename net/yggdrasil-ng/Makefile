include $(TOPDIR)/rules.mk

PKG_NAME:=yggdrasil-ng
PKG_VERSION:=0.1.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Revertron/Yggdrasil-ng/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a8ec3727c17873747f3cf91c5fd6dad403747d245f964141b8e465f469412522
PKG_BUILD_DIR:=$(BUILD_DIR)/Yggdrasil-ng-$(PKG_VERSION)

PKG_MAINTAINER:=OverLessArtem <artemover@duck.com>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

# Workspace crate that contains the yggdrasil binary
MAKE_PATH:=crates/yggdrasil

define Package/yggdrasil-ng
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Yggdrasil mesh network (Rust rewrite)
  URL:=https://github.com/Revertron/Yggdrasil-ng
  DEPENDS:=$(RUST_ARCH_DEPENDS) @!i386_pentium-mmx @IPV6 +kmod-tun
endef

define Package/yggdrasil-ng/description
  Yggdrasil-ng is a Rust rewrite of the Yggdrasil Network — a fully
  end-to-end encrypted IPv6 mesh networking protocol. Wire-compatible
  with the original Go implementation.

  Features a smaller memory footprint, faster throughput, and a
  single binary (daemon + control tool combined). Supports TCP and
  TLS transports, Crypto-Key Routing (CKR) for VPN tunneling,
  multicast peer discovery, and a built-in stateful firewall.
endef

define Package/yggdrasil-ng/install
	$(INSTALL_DIR) \
		$(1)/etc/yggdrasil-ng \
		$(1)/etc/init.d \
		$(1)/usr/sbin

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/yggdrasil $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/yggdrasil-ng.init $(1)/etc/init.d/yggdrasil-ng
endef

$(eval $(call RustBinPackage,yggdrasil-ng))
$(eval $(call BuildPackage,yggdrasil-ng))
