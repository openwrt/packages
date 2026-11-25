include $(TOPDIR)/rules.mk

PKG_NAME:=netavark
PKG_VERSION:=2.1.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-vendor.tar.zst
PKG_SOURCE_URL:=@OPENWRT
PKG_SOURCE_PROTO:=cargo-vendor-github
PKG_VENDOR_REPO:=containers/netavark
PKG_VENDOR_TAG:=v$(PKG_VERSION)
PKG_VENDOR_HASH:=96677048168ddd1abe313e4c2e17f1cace72b60ee1bac8ca12a4bd7dfcadfbbb
PKG_HASH:=76b84dbd41b837fce2118c4260be8d16061bbdd8ecbad5609dc42175ac30409d

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=protobuf/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/rust-package.mk

define Package/netavark
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=$(RUST_PKG_DEPENDS) +nftables-json +kmod-nft-nat
  TITLE:=A container network stack
  URL:=https://github.com/containers/netavark
endef

define Package/netavark/description
  Netavark is a rust based network stack for containers. It is being designed to work with Podman but is also
  applicable for other OCI container management applications.
endef

CARGO_PKG_VARS += \
	PROTOC=$(STAGING_DIR_HOSTPKG)/bin/protoc \
	NETAVARK_DEFAULT_FW=nftables

define Package/netavark/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/usr/lib/podman
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/netavark $(1)/usr/lib/podman
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/netavark-dhcp-proxy-client $(1)/usr/lib/podman/
endef

$(eval $(call RustBinPackage,netavark))
$(eval $(call BuildPackage,netavark))
