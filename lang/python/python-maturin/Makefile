# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato

include $(TOPDIR)/rules.mk

PKG_NAME:=python-maturin
PKG_VERSION:=1.15.0
PKG_RELEASE:=2

PYPI_NAME:=maturin
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-vendor.tar.zst
PKG_SOURCE_URL:=@OPENWRT
PKG_SOURCE_PROTO:=cargo-vendor-archive
PKG_VENDOR_FILE:=$(PYPI_NAME)-$(PKG_VERSION).tar.gz
PKG_VENDOR_URL:=https://files.pythonhosted.org/packages/source/m/$(PYPI_NAME)
PKG_VENDOR_HASH:=94b26cc8e8aba61a5f2099715fe640e18c5f678e9a500408b38761263954228a
PKG_HASH:=0572e3feb48168bd94c3c1a7f624d860aa44ef7ac50fc9619ac93a8ca786c900

PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=license-apache license-mit

HOST_BUILD_DEPENDS:= \
	python3/host \
	python-setuptools/host \
	python-build/host \
	python-installer/host \
	python-wheel/host \
	python-setuptools-rust/host
HOST_BUILD_PARALLEL:=1
PKG_HOST_ONLY:=1

include ../pypi.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk
include ../python3-host-build.mk
include $(INCLUDE_DIR)/rust-values.mk

HOST_BUILD_DEPENDS+=$(RUST_HOST_BUILD_DEPENDS)

define Package/python3-maturin
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Build and publish crates as python packages
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  URL:=https://maturin.rs
  BUILDONLY:=1
endef

define Package/python3-maturin/description
  Build and publish crates with pyo3, rust-cpython, cffi and uniffi
  bindings as well as rust binaries as python packages.
endef

$(eval $(call HostBuild))
$(eval $(call Py3Package,python3-maturin))
$(eval $(call BuildPackage,python3-maturin))
$(eval $(call BuildPackage,python3-maturin-src))
