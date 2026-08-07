#
# Copyright (C) 2026 Josef Schlehofer
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=librespeed-cli-rust
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/BKPepe/speedtest-cli-rust.git
PKG_SOURCE_VERSION:=25a9e9f42deaa3dbe77707c010bbd89c9f7b65bd
PKG_SOURCE_DATE:=2026-08-07
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.zst
PKG_MIRROR_HASH:=9434976b4dab03216025b239e76d3113ddda14c2e82ff56bd49e5f8e6b9fab20

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=LGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/librespeed-cli-rust
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Command line client for LibreSpeed (Rust)
  URL:=https://github.com/BKPepe/speedtest-cli-rust
  DEPENDS:=$(RUST_ARCH_DEPENDS) +libopenssl
  PROVIDES:=librespeed-cli
  CONFLICTS:=librespeed-cli
endef

define Package/librespeed-cli-rust/description
  LibreSpeed client for measuring internet speed from command line.

  This is a Rust port of librespeed/speedtest-cli. The original is written
  in Go, whose toolchain targets only ppc64 and ppc64le, so librespeed-cli
  is unavailable on 32-bit PowerPC devices. Both packages install
  /usr/bin/librespeed-cli, hence the conflict.
endef

# rustls' default crypto backend, ring, carries hand-written assembly per
# architecture and its build script rejects anything outside x86, x86_64,
# aarch64, arm and wasm32. Build against libopenssl instead, which is
# available for every architecture and avoids a second TLS stack in the image.
RUST_PKG_FEATURES:=native-tls

CARGO_PKG_VARS+= \
	OPENSSL_NO_VENDOR=1 \
	OPENSSL_INCLUDE_DIR=$(STAGING_DIR)/usr/include \
	OPENSSL_LIB_DIR=$(STAGING_DIR)/usr/lib \
	PKG_CONFIG_ALLOW_CROSS=1

# rust-package.mk has no switch for --no-default-features, so pass it through
# the second argument of Build/Compile/Cargo.
define Build/Compile
	$(call Build/Compile/Cargo,,--no-default-features)
endef

$(eval $(call RustBinPackage,librespeed-cli-rust))
$(eval $(call BuildPackage,librespeed-cli-rust))
