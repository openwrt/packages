#
# Copyright (C) 2019-2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-py
PKG_VERSION:=1.8.1
PKG_RELEASE:=1

PYPI_NAME:=py
PKG_HASH:=5e27081401262157467ad6e7f851b7aa402c5852dbcb3dae06768434de5752aa

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:=setuptools-scm

define Package/python3-py
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=py
  URL:=https://github.com/pytest-dev/py
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python3-py/description
  Library with cross-python path, ini-parsing, io, code, log facilities
endef

$(eval $(call Py3Package,python3-py))
$(eval $(call BuildPackage,python3-py))
$(eval $(call BuildPackage,python3-py-src))
