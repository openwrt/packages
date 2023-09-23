# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato

include $(TOPDIR)/rules.mk

PKG_NAME:=maturin
PKG_VERSION:=0.14.15
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/PyO3/maturin/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=60cbf8ff73a36333c3f5483ca679a52169839db381f06683d8e61a6c00c28cf7

PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=license-apache license-mit

HOST_BUILD_DEPENDS:=rust/host
HOST_BUILD_PARALLEL:=1
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../rust/rust-host-build.mk

define Package/maturin
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Rust
  TITLE:=Build and publish crates as python packages
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  URL:=https://maturin.rs
endef

define Package/maturin/description
  Build and publish crates with pyo3, rust-cpython, cffi and uniffi
  bindings as well as rust binaries as python packages.
endef

$(eval $(call RustBinHostBuild))
$(eval $(call HostBuild))
$(eval $(call BuildPackage,maturin))
