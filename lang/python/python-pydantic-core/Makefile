#
# Copyright (C) 2024, Clouder Oy
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pydantic-core
PKG_VERSION:=2.20.1
PKG_RELEASE:=1

PYPI_NAME:=pydantic_core

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Ilkka Ollakka <ilkka.ollakka@cloudersolutions.com>
PKG_HASH:=26ca695eeee5f9f1aeeb211ffc12f10bcb6f71e2989988fda61dabd65db878d4

PKG_BUILD_DEPENDS:=python-maturin/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pydantic-core
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Pydantic-core
  URL:=https://github.com/pydantic/pydantic-core
  DEPENDS:= \
      +python3-light \
      $(RUST_ARCH_DEPENDS)
endef

define Package/python3-pydantic-core/description
This package provides the core functionality for pydantic validation and serialization.
endef

$(eval $(call Py3Package,python3-pydantic-core))
$(eval $(call BuildPackage,python3-pydantic-core))
$(eval $(call BuildPackage,python3-pydantic-core-src))
