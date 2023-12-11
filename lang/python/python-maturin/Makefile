# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Luca Barbato

include $(TOPDIR)/rules.mk

PKG_NAME:=python-maturin
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PYPI_NAME:=maturin
PKG_HASH:=f6c69bc7ae147a5effd55587447b35cab1ceb726ba244d08698bc7518b8688ac

PKG_MAINTAINER:=Luca Barbato <lu_zero@luminem.org>
PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=license-apache license-mit

HOST_BUILD_DEPENDS:= \
	python3/host \
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
