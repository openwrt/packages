#
# Copyright (C) 2026 Josef Schlehofer
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=librespeed-cli-rust
PKG_VERSION:=1.2.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/librespeed/speedtest-cli-rust/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=14362549f3f210b6aa6cd1f06bf00e115f9f82519cff756264718f8f1bd53b2b
PKG_BUILD_DIR:=$(BUILD_DIR)/speedtest-cli-rust-$(PKG_VERSION)

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=LGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/librespeed-cli-rust
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Command line client for LibreSpeed (Rust)
  URL:=https://github.com/librespeed/speedtest-cli-rust
  DEPENDS:=$(RUST_ARCH_DEPENDS) +libopenssl
  PROVIDES:=@librespeed-cli
  CONFLICTS:=librespeed-cli
  DEFAULT_VARIANT:=1
endef

define Package/librespeed-cli-rust/description
  LibreSpeed client for measuring internet speed from command line.

  This is a Rust port of librespeed/speedtest-cli. The original is written
  in Go, whose toolchain targets only ppc64 and ppc64le, so librespeed-cli
  is unavailable on 32-bit PowerPC devices. Both packages install
  /usr/bin/librespeed-cli, hence the conflict.
endef

# rustls' default crypto backend, ring, does build here, but it has no assembly
# for big-endian PowerPC and falls back to its portable C: on mpc85xx its
# AES-GCM measured under half of libopenssl's throughput. libopenssl is in the
# image anyway, so linking against it is both faster and one TLS stack fewer.
RUST_PKG_FEATURES:=native-tls
CARGO_PKG_ARGS+= --no-default-features

CARGO_PKG_VARS+= \
	OPENSSL_NO_VENDOR=1 \
	OPENSSL_INCLUDE_DIR=$(STAGING_DIR)/usr/include \
	OPENSSL_LIB_DIR=$(STAGING_DIR)/usr/lib \
	PKG_CONFIG_ALLOW_CROSS=1

$(eval $(call RustBinPackage,librespeed-cli-rust))
$(eval $(call BuildPackage,librespeed-cli-rust))
