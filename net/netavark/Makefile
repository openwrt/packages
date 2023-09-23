include $(TOPDIR)/rules.mk

PKG_NAME:=netavark
PKG_VERSION:=1.8.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/containers/netavark/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b1422ef6927458e9f80f7d322b751e29ab5d04d8ed6cb065baa82fa4291af10f

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:= \
	rust/host \
	protobuf/host
PKG_BUILD_PARALLEL:=1

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

CARGO_PKG_VARS += \
	PROTOC=$(STAGING_DIR_HOSTPKG)/bin/protoc

define Package/netavark/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/usr/lib/podman
	$(INSTALL_CONF) ./files/netavark-config $(1)/etc/config/netavark
	$(INSTALL_BIN) ./files/netavark-wrapper $(1)/usr/lib/podman/netavark
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/netavark $(1)/usr/lib/podman/netavark-bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/netavark-dhcp-proxy-client $(1)/usr/lib/podman/
endef

$(eval $(call RustBinPackage,netavark))
$(eval $(call BuildPackage,netavark))
