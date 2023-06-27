#
# Copyright (C) 2020-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pytest
PKG_VERSION:=7.3.0
PKG_RELEASE:=2

PYPI_NAME:=pytest
PKG_HASH:=58ecc27ebf0ea643ebfdf7fb1249335da761a00c9f955bcd922349bcb68ee57d

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-setuptools-scm/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pytest
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python testing framework
  URL:=https://docs.pytest.org/en/latest/
  DEPENDS:= \
	+python3 \
	+python3-pluggy \
	+python3-packaging \
	+python3-exceptiongroup \
	+python3-iniconfig
endef

define Package/python3-pytest/description
  The pytest framework makes it easy to write small tests, yet scales to support
  complex functional testing for applications and libraries.
endef

$(eval $(call Py3Package,python3-pytest))
$(eval $(call BuildPackage,python3-pytest))
$(eval $(call BuildPackage,python3-pytest-src))
