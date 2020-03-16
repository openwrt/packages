#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-enum34
PKG_VERSION:=1.1.10
PKG_RELEASE:=1

PYPI_NAME:=enum34
PKG_HASH:=cce6a7477ed816bd2542d03d53db9f0db935dd013b70f336a95c73979289f248

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=enum/LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>
PKG_CPE_ID:=cpe:/a:python:enum34

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-enum34/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Backported Python 3.4 enum
  URL:=https://bitbucket.org/stoneleaf/enum34
endef

define Package/python-enum34
$(call Package/python-enum34/Default)
  DEPENDS:=+PACKAGE_python-enum34:python-light
  VARIANT:=python
endef

define Package/python-enum34/description
enum34 is the new Python stdlib enum module available in Python 3.4
backported for previous versions of Python from 2.4 to 3.3.
endef

define PyPackage/python-enum34/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/enum/test.py
endef

$(eval $(call PyPackage,python-enum34))
$(eval $(call BuildPackage,python-enum34))
$(eval $(call BuildPackage,python-enum34-src))
