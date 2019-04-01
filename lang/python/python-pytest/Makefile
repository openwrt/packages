#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pytest
PKG_VERSION:=5.0.0
PKG_RELEASE:=1

PKG_SOURCE:=pytest-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pytest/
PKG_HASH:=95b700cf21ed5b7e91bce7a6b5a573b2e3ef7b3643d00f681d8f9c4672f9fbdf
PKG_BUILD_DIR:=$(BUILD_DIR)/pytest-$(PKG_VERSION)

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

PYTHON3_PKG_SETUP_VARS:= \
        PKG_VERSION="$(PKG_VERSION)"

PKG_BUILD_DEPENDS:=+python3-setuptools

define Package/python3-pytest
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python testing framework
  URL:=https://docs.pytest.org/en/latest/
  DEPENDS:= \
	+python3-light \
	+python3-atomicwrites \
	+python3-more-itertools \
	+python3-py \
	+python3-attrs \
	+python3-pluggy \
	+python3-importlib-metadata \
	+python3-packaging \
	+python3-wcwidth
  VARIANT:=python3
endef

define Py3Build/Compile
	echo "version = \"$(PKG_VERSION)\"" > $(PKG_BUILD_DIR)/src/_pytest/_version.py
	$(call Py3Build/Compile/Default)
endef

define Package/python3-pytest/description
  The pytest framework makes it easy to write small tests, yet scales to support
  complex functional testing for applications and libraries.
endef

$(eval $(call Py3Package,python3-pytest))
$(eval $(call BuildPackage,python3-pytest))
$(eval $(call BuildPackage,python3-pytest-src))
