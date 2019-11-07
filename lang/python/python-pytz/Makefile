#
# Copyright (C) 2007-2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pytz
PKG_VERSION:=2019.3
PKG_RELEASE:=1

PYPI_NAME:=pytz
PKG_HASH:=b02c06db6cf09c12dd25137e563b31700d3b80fcc4ad23abb7a315f2789819be

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-pytz/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  URL:=https://pythonhosted.org/pytz/
endef

define Package/python-pytz
$(call Package/python-pytz/Default)
  TITLE:=World timezone definitions, modern and historical
  DEPENDS:=+PACKAGE_python-pytz:python-light
  VARIANT:=python
endef

define Package/python3-pytz
$(call Package/python-pytz/Default)
  TITLE:=World timezone definitions, modern and historical for Python3
  DEPENDS:=+PACKAGE_python3-pytz:python3-light
  VARIANT:=python3
endef

define Package/python-pytz/description
  World timezone definitions, modern and historical
endef

define Package/python3-pytz/description
$(call Package/python-pytz/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-pytz))
$(eval $(call BuildPackage,python-pytz))
$(eval $(call BuildPackage,python-pytz-src))

$(eval $(call Py3Package,python3-pytz))
$(eval $(call BuildPackage,python3-pytz))
$(eval $(call BuildPackage,python3-pytz-src))
