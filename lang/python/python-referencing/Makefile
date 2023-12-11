#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-referencing
PKG_VERSION:=0.31.1
PKG_RELEASE:=1

PYPI_NAME:=referencing
PKG_HASH:=81a1471c68c9d5e3831c30ad1dd9815c45b558e596653db751a2bfdd17b3b9ec

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

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
    +python3-email \
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
