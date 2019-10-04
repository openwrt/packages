#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-simplejson
PKG_VERSION:=3.16.0
PKG_RELEASE:=2
PKG_LICENSE:=MIT
PKG_CPE_ID:=cpe:/a:simplejson_project:simplejson

PKG_SOURCE:=simplejson-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/s/simplejson
PKG_HASH:=b1f329139ba647a9548aa05fb95d046b4a677643070dc2afc05fa2e975d09ca5
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-simplejson-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

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

$(eval $(call PyPackage,python-simplejson))
$(eval $(call BuildPackage,python-simplejson))
$(eval $(call BuildPackage,python-simplejson-src))

$(eval $(call Py3Package,python3-simplejson))
$(eval $(call BuildPackage,python3-simplejson))
$(eval $(call BuildPackage,python3-simplejson-src))
