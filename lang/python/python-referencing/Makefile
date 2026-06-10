#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-referencing
PKG_VERSION:=0.37.0
PKG_RELEASE:=2

PYPI_NAME:=referencing
PKG_HASH:=44aefc3142c5b842538163acb373e24cce6632bd54bdb01b21ad5863489f50d8

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:=python-hatchling/host python-hatch-vcs/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-referencing
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=JSON Referencing + Python
  URL:=https://github.com/python-jsonschema/referencing
  DEPENDS:= \
    +python3-light \
    +python3-urllib \
    +python3-attrs \
    +python3-rpds-py
endef

define Package/python3-referencing/description
An implementation-agnostic implementation of JSON reference resolution.
endef

$(eval $(call Py3Package,python3-referencing))
$(eval $(call BuildPackage,python3-referencing))
$(eval $(call BuildPackage,python3-referencing-src))
