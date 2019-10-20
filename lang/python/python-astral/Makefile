#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-astral
PKG_VERSION:=1.10.1
PKG_RELEASE:=1

PYPI_NAME:=astral
PKG_HASH:=d2a67243c4503131c856cafb1b1276de52a86e5b8a1d507b7e08bee51cb67bf1

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-astral/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Calculations for the position of the sun and moon
  URL:=https://github.com/sffjunkie/astral
endef

define Package/python-astral
$(call Package/python-astral/Default)
  DEPENDS+= \
      +PACKAGE_python-astral:python-light \
      +PACKAGE_python-astral:python-pytz
  VARIANT:=python
endef

define Package/python3-astral
$(call Package/python-astral/Default)
  DEPENDS+= \
      +PACKAGE_python3-astral:python3-light \
      +PACKAGE_python3-astral:python3-pytz
  VARIANT:=python3
endef

define Package/python-astral/description
Astral is a python module for calculating the times of various aspects of the sun and moon.
endef

define Package/python3-astral/description
$(call Package/python-astral/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-astral))
$(eval $(call BuildPackage,python-astral))
$(eval $(call BuildPackage,python-astral-src))

$(eval $(call Py3Package,python3-astral))
$(eval $(call BuildPackage,python3-astral))
$(eval $(call BuildPackage,python3-astral-src))
