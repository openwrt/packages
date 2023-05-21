include $(TOPDIR)/rules.mk

PKG_NAME:=netavark
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/containers/netavark.git
PKG_SOURCE_DATE:=2023-05-12
PKG_SOURCE_VERSION:=07d63eadef1def977f2ece25b0f464f7e5d77be1
PKG_MIRROR_HASH:=f7597d70528d039b984b2ecc6ef0e1f1c17aacfc7862907e5a79789ebe98aa89

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:= \
	rust/host \
	protobuf/host

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/netavark
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  TITLE:=A container network stack
  URL:=https://github.com/containers/netavark
endef

define Package/netavark/description
  Netavark is a rust based network stack for containers. It is being designed to work with Podman but is also
  applicable for other OCI container management applications.
endef

define Package/netavark/conffiles
/etc/config/netavark
endef

CARGO_VARS += \
	PROTOC=$(STAGING_DIR_HOSTPKG)/bin/protoc

define Package/netavark/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/usr/lib/podman
	$(INSTALL_CONF) ./files/netavark-config $(1)/etc/config/netavark
	$(INSTALL_BIN) ./files/netavark-wrapper $(1)/usr/lib/podman/netavark
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/netavark $(1)/usr/lib/podman/netavark-bin
endef

$(eval $(call RustBinPackage,netavark))
$(eval $(call BuildPackage,netavark))
