#
# Copyright (C) 2006-2011 OpenWrt.org
# Copyright (C) 2015-2016, 2018-2021, 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-zope-interface
PKG_VERSION:=8.0.1
PKG_RELEASE:=1

PYPI_NAME:=zope.interface
PYPI_SOURCE_NAME:=zope_interface
PKG_HASH:=eba5610d042c3704a48222f7f7c6ab5b243ed26f917e2bc69379456b115e02d1

PKG_LICENSE:=ZPL-2.1
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=

PKG_BUILD_DEPENDS:= \
	python3/host \
	python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-zope-interface
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Interfaces for Python
  URL:=https://github.com/zopefoundation/zope.interface
  DEPENDS:=+python3-light +python3-logging
endef

define Package/python3-zope-interface/description
This package provides an implementation of "object interfaces" for
Python. Interfaces are a mechanism for labeling objects as conforming to
a given API or contract. So, this package can be considered as
implementation of the Design By Contract methodology support in Python.
endef

$(eval $(call Py3Package,python3-zope-interface))
$(eval $(call BuildPackage,python3-zope-interface))
$(eval $(call BuildPackage,python3-zope-interface-src))
