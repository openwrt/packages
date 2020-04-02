#
# Copyright (C) 2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=python-packaging
PKG_VERSION:=20.3
PKG_RELEASE:=1

PYPI_NAME:=packaging
PKG_HASH:=3c292b474fda1671ec57d46d739d072bfd495a4f51ad01a055121d81e952b7a3

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=Apache-2.0 BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.APACHE LICENSE.BSD

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-packaging
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Core utilities for Python packages
  URL:=https://github.com/pypa/packaging
  DEPENDS:=+python3-light +python3-pyparsing +python3-six +python3-logging +python3-distutils
  VARIANT:=python3
endef

define Package/python3-packaging/description
  The packaging project includes version handling, specifiers,
  markers, requirements, tags, utilities.
endef

$(eval $(call Py3Package,python3-packaging))
$(eval $(call BuildPackage,python3-packaging))
$(eval $(call BuildPackage,python3-packaging-src))
