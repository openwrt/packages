#
# Copyright (C) 2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ujson
PKG_VERSION:=1.35
PKG_RELEASE:=1

PKG_SOURCE:=ujson-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/16/c4/79f3409bc710559015464e5f49b9879430d8f87498ecdc335899732e5377/
PKG_HASH:=f66073e5506e91d204ab0c614a148d5aa938bdbf104751be66f8ad7a222f5f86

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-ujson-$(PKG_VERSION)

PKG_LICENSE:=BSD License
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-ujson/Default
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://pypi.org/project/ujson/
endef

define Package/python-ujson
$(call Package/python-ujson/Default)
  TITLE:=python-ujson
  DEPENDS:=+PACKAGE_python-ujson:python-light
  VARIANT:=python
endef

define Package/python3-ujson
$(call Package/python-ujson/Default)
  TITLE:=python3-ujson
  DEPENDS:=+PACKAGE_python3-ujson:python3-light
  VARIANT:=python3
endef

define Package/python-ujson/description
UltraJSON is an ultra fast JSON encoder and decoder written in pure C with
bindings for Python 2.5+ and 3.
endef

define Package/python3-ujson/description
$(call Package/python-ujson/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-ujson))
$(eval $(call BuildPackage,python-ujson))
$(eval $(call BuildPackage,python-ujson-src))

$(eval $(call Py3Package,python3-ujson))
$(eval $(call BuildPackage,python3-ujson))
$(eval $(call BuildPackage,python3-ujson-src))
