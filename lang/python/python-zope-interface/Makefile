#
# Copyright (C) 2006-2011, 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-zope-interface
PKG_VERSION:=5.1.2
PKG_RELEASE:=1

PYPI_NAME:=zope.interface
PKG_HASH:=c9c8e53a5472b77f6a391b515c771105011f4b40740ce53af8428d1c8ca20004

PKG_LICENSE:=ZPL-2.1
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-zope-interface
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Interfaces for Python
  URL:=https://github.com/zopefoundation/zope.interface
  DEPENDS:=+python3-light
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
