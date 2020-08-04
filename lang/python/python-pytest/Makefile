#
# Copyright (C) 2020 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pytest
PKG_VERSION:=6.0.1
PKG_RELEASE:=1

PYPI_NAME:=pytest
PKG_HASH:=85228d75db9f45e06e57ef9bf4429267f81ac7c0d742cc9ed63d09886a9fe6f4

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=0
HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:=setuptools-scm

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
	+python3-more-itertools \
	+python3-py \
	+python3-attrs \
	+python3-pluggy \
	+python3-packaging \
	+python3-toml \
	+python3-iniconfig
endef

define Package/python3-pytest/description
  The pytest framework makes it easy to write small tests, yet scales to support
  complex functional testing for applications and libraries.
endef

$(eval $(call Py3Package,python3-pytest))
$(eval $(call BuildPackage,python3-pytest))
$(eval $(call BuildPackage,python3-pytest-src))
