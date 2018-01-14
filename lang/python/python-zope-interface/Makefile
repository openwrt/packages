#
# Copyright (C) 2006-2011, 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-zope-interface
PKG_VERSION:=4.4.3
PKG_RELEASE:=2

PKG_SOURCE:=zope.interface-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/bd/d2/25349ed41f9dcff7b3baf87bd88a4c82396cf6e02f1f42bb68657a3132af
PKG_HASH:=d6d26d5dfbfd60c65152938fcb82f949e8dada37c041f72916fef6621ba5c5ce

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-zope-interface-$(PKG_VERSION)

PKG_LICENSE:=ZPL-2.1
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-zope-interface/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/zopefoundation/zope.interface
endef

define Package/python-zope-interface
$(call Package/python-zope-interface/Default)
  TITLE:=python-zope-interface
  DEPENDS:=+PACKAGE_python-zope-interface:python-light
  VARIANT:=python
endef

define Package/python3-zope-interface
$(call Package/python-zope-interface/Default)
  TITLE:=python3-zope-interface
  DEPENDS:=+PACKAGE_python3-zope-interface:python3-light
  VARIANT:=python3
endef

define Package/python-zope-interface/description
This package provides an implementation of "object interfaces" for
Python. Interfaces are a mechanism for labeling objects as conforming to
a given API or contract. So, this package can be considered as
implementation of the Design By Contract methodology support in Python.
endef

define Package/python3-zope-interface/description
$(call Package/python-zope-interface/description)
.
(Variant for Python3)
endef

define PyPackage/python-zope-interface/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/zope/interface/common/tests
-|$(PYTHON_PKG_DIR)/zope/interface/tests
endef

define Py3Package/python3-zope-interface/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/zope/interface/common/tests
-|$(PYTHON3_PKG_DIR)/zope/interface/tests
endef

$(eval $(call PyPackage,python-zope-interface))
$(eval $(call BuildPackage,python-zope-interface))
$(eval $(call BuildPackage,python-zope-interface-src))

$(eval $(call Py3Package,python3-zope-interface))
$(eval $(call BuildPackage,python3-zope-interface))
$(eval $(call BuildPackage,python3-zope-interface-src))
