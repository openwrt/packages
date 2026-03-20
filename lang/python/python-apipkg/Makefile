#
# Copyright (C) 2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-apipkg
PKG_VERSION:=3.0.2
PKG_RELEASE:=1

PYPI_NAME:=apipkg
PKG_HASH:=c7aa61a4f82697fdaa667e70af1505acf1f7428b1c27b891d204ba7a8a3c5e0d

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-hatchling/host python-hatch-vcs/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-apipkg
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Namespace control and lazy-import mechanism
  URL:=https://github.com/pytest-dev/apipkg
  DEPENDS:=+python3-light
endef

define Package/python3-apipkg/description
apipkg is used to control the exported namespace of a Python package and
greatly reduce the number of imports for users.
endef

$(eval $(call Py3Package,python3-apipkg))
$(eval $(call BuildPackage,python3-apipkg))
$(eval $(call BuildPackage,python3-apipkg-src))
