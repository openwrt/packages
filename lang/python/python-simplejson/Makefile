#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-simplejson
PKG_VERSION:=3.17.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT
PKG_CPE_ID:=cpe:/a:simplejson_project:simplejson

PYPI_NAME:=simplejson
PKG_HASH:=2b4b2b738b3b99819a17feaf118265d0753d5536049ea570b3c43b51c4701e81

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-simplejson/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
  URL:=https://simplejson.readthedocs.org/
endef

define Package/python-simplejson
$(call Package/python-simplejson/Default)
  TITLE:=Simple, fast, extensible JSON encoder/decoder for Python 2
  DEPENDS:=+PACKAGE_python-simplejson:python-light +PACKAGE_python-simplejson:python-decimal
  VARIANT:=python
endef

define Package/python3-simplejson
$(call Package/python-simplejson/Default)
  TITLE:=Simple, fast, extensible JSON encoder/decoder for Python3
  DEPENDS:=+PACKAGE_python3-simplejson:python3-light +PACKAGE_python3-simplejson:python3-decimal
  VARIANT:=python3
endef

define Package/python-simplejson/description
  Simple, fast, extensible JSON encoder/decoder for Python
endef

define Package/python3-simplejson/description
$(call Package/python-simplejson/description)
.
(Variant for Python3)
endef

define PyPackage/python-simplejson/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/simplejson/tests
endef

define Py3Package/python3-simplejson/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/simplejson/tests
endef

$(eval $(call PyPackage,python-simplejson))
$(eval $(call BuildPackage,python-simplejson))
$(eval $(call BuildPackage,python-simplejson-src))

$(eval $(call Py3Package,python3-simplejson))
$(eval $(call BuildPackage,python3-simplejson))
$(eval $(call BuildPackage,python3-simplejson-src))
