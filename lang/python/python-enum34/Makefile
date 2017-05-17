#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=enum34
PKG_VERSION:=1.1.6
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/bf/3e/31d502c25302814a7c2f1d3959d2a3b3f78e509002ba91aea64993936876
PKG_MD5SUM:=5f13a0841a61f7fc295c514490d120d0

PKG_BUILD_DEPENDS:=python python-setuptools

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=enum/LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-enum34
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-enum34
	URL:=https://pypi.python.org/pypi/enum34/
	DEPENDS:=+python-light
endef

define Package/python-enum34/description
enum34 is the new Python stdlib enum module available in Python 3.4
backported for previous versions of Python from 2.4 to 3.3.
endef

define PyPackage/python-enum34/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/enum/test.py
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

$(eval $(call PyPackage,python-enum34))
$(eval $(call BuildPackage,python-enum34))
