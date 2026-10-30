#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-rpds-py
PKG_VERSION:=2026.9.1
PKG_RELEASE:=2

PYPI_NAME:=rpds-py
PYPI_SOURCE_NAME:=rpds_py
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-vendor.tar.zst
PKG_SOURCE_URL:=@OPENWRT
PKG_SOURCE_PROTO:=cargo-vendor-archive
PKG_VENDOR_FILE:=$(PYPI_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_VENDOR_URL:=https://files.pythonhosted.org/packages/source/r/$(PYPI_NAME)
PKG_VENDOR_HASH:=4793ef7f78268b124b73fa933440f01d258bbae01de9fa53e9080c9ab0425a12
PKG_HASH:=c09d674fd9536836b7e2b95e71b7c84f627fca69590c3aa4c12c61a0d5afb936

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:=python-maturin/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk
include $(INCLUDE_DIR)/rust-values.mk

PKG_BUILD_DEPENDS+=$(RUST_PKG_BUILD_DEPENDS)
PKG_CONFIG_DEPENDS+=$(RUST_PKG_CONFIG_DEPENDS)

define Package/python3-rpds-py
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Bindings to Rust's persistent data structures
  URL:=https://github.com/crate-py/rpds
  DEPENDS:=+python3-light $(RUST_PKG_DEPENDS)
endef

define Package/python3-rpds-py/description
Python bindings to the Rust rpds crate for persistent data structures.
endef

$(eval $(call Py3Package,python3-rpds-py))
$(eval $(call BuildPackage,python3-rpds-py))
$(eval $(call BuildPackage,python3-rpds-py-src))
