#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-enum34
PKG_VERSION:=1.1.6
PKG_RELEASE:=3

PKG_SOURCE:=enum34-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/bf/3e/31d502c25302814a7c2f1d3959d2a3b3f78e509002ba91aea64993936876
PKG_HASH:=8ad8c4783bf61ded74527bffb48ed9b54166685e4230386a9ed9b1279e2df5b1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-enum34-$(PKG_VERSION)

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=enum/LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-enum34/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://pypi.python.org/pypi/enum34/
endef

define Package/python-enum34
$(call Package/python-enum34/Default)
  TITLE:=python-enum34
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
