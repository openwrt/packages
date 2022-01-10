#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-simplejson
PKG_VERSION:=3.17.5
PKG_RELEASE:=$(AUTORELEASE)
PKG_LICENSE:=MIT
PKG_CPE_ID:=cpe:/a:simplejson_project:simplejson

PYPI_NAME:=simplejson
PKG_HASH:=91cfb43fb91ff6d1e4258be04eee84b51a4ef40a28d899679b9ea2556322fb50
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-simplejson
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
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
