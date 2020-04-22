#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-simplejson
PKG_VERSION:=3.17.0
PKG_RELEASE:=2
PKG_LICENSE:=MIT
PKG_CPE_ID:=cpe:/a:simplejson_project:simplejson

PYPI_NAME:=simplejson
PKG_HASH:=2b4b2b738b3b99819a17feaf118265d0753d5536049ea570b3c43b51c4701e81

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-simplejson
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
  TITLE:=Simple, fast, extensible JSON encoder/decoder
  URL:=https://simplejson.readthedocs.org/
  DEPENDS:=+python3-light +python3-decimal
endef

define Package/python3-simplejson/description
  Simple, fast, extensible JSON encoder/decoder for Python
endef

define Py3Package/python3-simplejson/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/simplejson/tests
endef

$(eval $(call Py3Package,python3-simplejson))
$(eval $(call BuildPackage,python3-simplejson))
$(eval $(call BuildPackage,python3-simplejson-src))
