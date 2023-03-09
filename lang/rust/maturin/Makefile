# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato

include $(TOPDIR)/rules.mk

PKG_NAME:=maturin
PKG_VERSION:=0.14.10
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/PyO3/maturin/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=8fc9bcdcb7f1535d5e3e8bb500c348ca1bff5a6dce87b0ab7dbc5a49723da28a

PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=license-apache license-mit

HOST_BUILD_DEPENDS:=rust/host
PKG_BUILD_DEPENDS:=rust/host

PKG_BUILD_PARALLEL:=1
PKG_HOST_ONLY:=1

include ../rust-package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/maturin
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Rust
  TITLE:=Build and publish crates as python packages
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  URL:=https://maturin.rs
endef

define Host/Compile
	$(call Host/Compile/Cargo)
endef

define Package/maturin/description
  Build and publish crates with pyo3, rust-cpython, cffi and uniffi
  bindings as well as rust binaries as python packages.
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin
	$(INSTALL_BIN) $(HOST_INSTALL_DIR)/bin/maturin $(STAGING_DIR_HOSTPKG)/bin/maturin
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,maturin))
