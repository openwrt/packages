#
# Copyright (C) 2019-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-py
PKG_VERSION:=1.11.0
PKG_RELEASE:=1

PYPI_NAME:=py
PKG_HASH:=51c75c4126074b472f746a24399ad32f6053d1b34b68d2fa41e558e6f4a98719

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:pytest:py

PKG_BUILD_DEPENDS:=python-setuptools-scm/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-py
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python development support library
  URL:=https://github.com/pytest-dev/py
  DEPENDS:=+python3-light +python3-xml +python3-urllib +python3-uuid
endef

define Package/python3-py/description
  Library with cross-python path, ini-parsing, io, code, log facilities
endef

$(eval $(call Py3Package,python3-py))
$(eval $(call BuildPackage,python3-py))
$(eval $(call BuildPackage,python3-py-src))
