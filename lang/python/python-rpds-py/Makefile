#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-rpds-py
PKG_VERSION:=2026.6.3
PKG_RELEASE:=1

PYPI_NAME:=rpds-py
PYPI_SOURCE_NAME:=rpds_py
PKG_HASH:=1cebd1337c242e4ec2293e541f712b2da849b29f48f0c293684b71c0632625d4

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:=python-maturin/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-rpds-py
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Bindings to Rust's persistent data structures
  URL:=https://github.com/crate-py/rpds
  DEPENDS:=+python3-light $(RUST_ARCH_DEPENDS)
endef

define Package/python3-rpds-py/description
Python bindings to the Rust rpds crate for persistent data structures.
endef

$(eval $(call Py3Package,python3-rpds-py))
$(eval $(call BuildPackage,python3-rpds-py))
$(eval $(call BuildPackage,python3-rpds-py-src))
