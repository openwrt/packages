#
# Copyright (C) 2020-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=python-packaging
PKG_VERSION:=26.0
PKG_RELEASE:=1

PYPI_NAME:=packaging
PKG_HASH:=00243ae351a257117b6a241061796684b084ed1c516a08c48a3f7e147a9d80b4

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=Apache-2.0 BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.APACHE LICENSE.BSD

PKG_BUILD_DEPENDS:=python-flit-core/host
HOST_BUILD_DEPENDS:=python3/host python-flit-core/host python-installer/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-packaging
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Core utilities for Python packages
  URL:=https://github.com/pypa/packaging
  DEPENDS:=+python3-light +python3-email +python3-logging
endef

define Package/python3-packaging/description
  The packaging project includes version handling, specifiers,
  markers, requirements, tags, utilities.
endef

Host/Compile=$(Py3Host/Compile/Bootstrap)

$(eval $(call Py3Package,python3-packaging))
$(eval $(call BuildPackage,python3-packaging))
$(eval $(call BuildPackage,python3-packaging-src))
$(eval $(call HostBuild))
