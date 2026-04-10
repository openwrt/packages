#
# Copyright (C) 2020-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pytest-xdist
PKG_VERSION:=3.8.0
PKG_RELEASE:=1

PYPI_NAME:=pytest-xdist
PYPI_SOURCE_NAME:=pytest_xdist
PKG_HASH:=7e578125ec9bc6050861aa93f2d59f1d8d085595d6551c2c90b6f4fad8d3a9f1

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-setuptools-scm/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pytest-xdist
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=pytest plugin for distributed testing
  URL:=https://github.com/pytest-dev/pytest-xdist
  DEPENDS:= \
	+python3-light \
	+python3-uuid \
	+python3-execnet \
	+python3-pytest
endef

define Package/python3-pytest-xdist/description
The pytest-xdist plugin extends pytest with new test execution modes,
the most used being distributing tests across multiple CPUs to speed up
test execution.
endef

$(eval $(call Py3Package,python3-pytest-xdist))
$(eval $(call BuildPackage,python3-pytest-xdist))
$(eval $(call BuildPackage,python3-pytest-xdist-src))
