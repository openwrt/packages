#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zope.interface
PKG_VERSION:=4.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/ea/a3/38bdc8e8bd068ea5b4d21a2d80eca1547cd8509318e8d7c875f7247abe43
PKG_MD5SUM:=2950a6db7e985e19c7a846cc20f5d82a

PKG_BUILD_DEPENDS:=python python-setuptools

PKG_LICENSE:=ZPL-2.1
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/zope-interface
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Zope interface
  URL:=https://github.com/zopefoundation/zope.interface
  DEPENDS:=+python-light
endef

define Package/zope-interface/description
This package provides an implementation of "object interfaces" for
Python. Interfaces are a mechanism for labeling objects as conforming to
a given API or contract. So, this package can be considered as
implementation of the Design By Contract methodology support in Python.
endef

define PyPackage/zope-interface/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/zope/interface/common/tests
-|$(PYTHON_PKG_DIR)/zope/interface/tests
endef

define Build/Compile
	$(call Build/Compile/PyMod,, \
		install --prefix="/usr" --root="$(PKG_INSTALL_DIR)" --no-compile, \
	)
endef

$(eval $(call PyPackage,zope-interface))
$(eval $(call BuildPackage,zope-interface))
