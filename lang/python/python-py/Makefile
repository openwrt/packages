#
# Copyright (C) 2019-2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-py
PKG_VERSION:=1.9.0
PKG_RELEASE:=2

PYPI_NAME:=py
PKG_HASH:=9ca6883ce56b4e8da7e79ac18787889fa5206c79dcc67fb065376cd2fe03f342

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:=setuptools-scm

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-py
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=py
  URL:=https://github.com/pytest-dev/py
  DEPENDS:=+python3-light +python3-xml +python3-urllib
endef

define Package/python3-py/description
  Library with cross-python path, ini-parsing, io, code, log facilities
endef

$(eval $(call Py3Package,python3-py))
$(eval $(call BuildPackage,python3-py))
$(eval $(call BuildPackage,python3-py-src))
