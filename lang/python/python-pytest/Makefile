#
# Copyright (C) 2020-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pytest
PKG_VERSION:=7.4.0
PKG_RELEASE:=1

PYPI_NAME:=pytest
PKG_HASH:=b4bf8c45bd59934ed84001ad51e11b4ee40d40a1229d2c79f9c592b0a3f6bd8a

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
  URL:=https://pytest.org/
  DEPENDS:= \
	+python3 \
	+python3-iniconfig \
	+python3-packaging \
	+python3-pluggy
endef

define Package/python3-pytest/description
The pytest framework makes it easy to write small tests, yet scales to
support complex functional testing for applications and libraries.
endef

$(eval $(call Py3Package,python3-pytest))
$(eval $(call BuildPackage,python3-pytest))
$(eval $(call BuildPackage,python3-pytest-src))
