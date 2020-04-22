#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-voluptuous
PKG_VERSION:=0.11.7
PKG_RELEASE:=2

PYPI_NAME:=voluptuous
PKG_HASH:=2abc341dbc740c5e2302c7f9b8e2e243194fb4772585b991931cb5b22e9bf456

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-voluptuous
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Data validation library
  URL:=https://github.com/alecthomas/voluptuous
  DEPENDS:= \
      +python3-light
endef

define Package/python3-voluptuous/description
It is primarily intended for validating data coming into Python as JSON, YAML, etc.
endef

$(eval $(call Py3Package,python3-voluptuous))
$(eval $(call BuildPackage,python3-voluptuous))
$(eval $(call BuildPackage,python3-voluptuous-src))
