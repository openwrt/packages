#
# Copyright (C) 2020-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pytest
PKG_VERSION:=9.0.2
PKG_RELEASE:=1

PYPI_NAME:=pytest
PKG_HASH:=75186651a92bd89611d1d9fc20f0b4345fd827c41ccd5c299a868a05d70edf11

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>
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
	+python3-pluggy \
	+python3-pygments
endef

define Package/python3-pytest/description
The pytest framework makes it easy to write small tests, yet scales to
support complex functional testing for applications and libraries.
endef

$(eval $(call Py3Package,python3-pytest))
$(eval $(call BuildPackage,python3-pytest))
$(eval $(call BuildPackage,python3-pytest-src))
