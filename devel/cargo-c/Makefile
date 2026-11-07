# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Luca Barbato

include $(TOPDIR)/rules.mk

PKG_NAME:=cargo-c
PKG_VERSION:=0.10.13
PKG_RELEASE:=2

# The git tag has no Cargo.lock, the published crate has one.
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-vendor.tar.zst
PKG_SOURCE_URL:=@OPENWRT
PKG_SOURCE_PROTO:=cargo-vendor-archive
PKG_VENDOR_FILE:=$(PKG_NAME)-$(PKG_VERSION)+cargo-0.88.0.crate
PKG_VENDOR_URL:=https://static.crates.io/crates/$(PKG_NAME)
PKG_VENDOR_HASH:=bd11efb38aee5930cabfe8d41465f22859b2af9071fa04d3642814cf1cc2bc75
PKG_HASH:=a924faaf4e6812be40f3c28eb81e4055905815b82c05c3f5142fea0d04c91789

PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_PARALLEL:=1
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/rust-host-build.mk

define Package/cargo-c
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Rust
  TITLE:=Build and install rust crates as C libraries
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  URL:=https://github.com/lu-zero/cargo-c
  BUILDONLY:=1
endef

define Package/cargo-c/description
  Build and install crates with C bindings so they appear as normal
  C libraries.
endef

$(eval $(call RustBinHostBuild))
$(eval $(call HostBuild))
$(eval $(call BuildPackage,cargo-c))
