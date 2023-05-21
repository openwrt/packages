#
# Copyright (C) 2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pytest-forked
PKG_VERSION:=1.6.0
PKG_RELEASE:=1

PYPI_NAME:=pytest-forked
PKG_HASH:=4dafd46a9a600f65d822b8f605133ecf5b3e1941ebb3588e943b4e3eb71a5a3f

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-setuptools-scm/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pytest-forked
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Runs tests in isolated forked subprocesses
  URL:=https://github.com/pytest-dev/pytest-forked
  DEPENDS:= +python3-light +python3-pytest +python3-py
endef

define Package/python3-pytest-forked/description
  Pytest plugin which enables to run tests in isolated forked subprocesses
endef

$(eval $(call Py3Package,python3-pytest-forked))
$(eval $(call BuildPackage,python3-pytest-forked))
$(eval $(call BuildPackage,python3-pytest-forked-src))
