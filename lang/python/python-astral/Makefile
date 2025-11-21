#
# Copyright (C) 2019-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-astral
PKG_VERSION:=3.2
PKG_RELEASE:=1

PYPI_NAME:=astral
PKG_HASH:=9b7c3b412e9e69d172cfb24be0e6addcc9f1bd01a28db8bebe66d75ccc533d88

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>

PKG_BUILD_DEPENDS:=python-poetry-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-astral
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Calculations for the position of the sun and moon
  URL:=https://github.com/sffjunkie/astral
  DEPENDS+= \
      +python3-light
endef

define Package/python3-astral/description
Astral is a python module for calculating the times of various aspects of the sun and moon.
endef

$(eval $(call Py3Package,python3-astral))
$(eval $(call BuildPackage,python3-astral))
$(eval $(call BuildPackage,python3-astral-src))
