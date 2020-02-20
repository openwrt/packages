#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-appconf
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=35f13ca4d567f132b960e2cd4c832c2d03cb6543452d34e29b7ba10371ba80e3

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/django-appconf/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Helper class for handling config defaults
  URL:=https://django-appconf.readthedocs.io
endef

define Package/python-django-appconf
$(call Package/django-appconf/Default)
  DEPENDS:= \
	+PACKAGE_python-django-appconf:python \
	python-django1 \
	+PACKAGE_python-django-appconf:python-six
  VARIANT:=python
  MDEPENDS:=python-django1
endef

define Package/python-django-appconf/description
  A helper class for handling configuration defaults of packaged apps gracefully
endef

define Package/python3-django-appconf
$(call Package/django-appconf/Default)
  DEPENDS:= \
	+PACKAGE_python3-django-appconf:python3 \
	+PACKAGE_python3-django-appconf:python3-django1 \
	+PACKAGE_python3-django-appconf:python3-six
  VARIANT:=python3
endef

define Package/python3-django-appconf/description
$(call Package/python-django-appconf/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-django-appconf))
$(eval $(call BuildPackage,python-django-appconf))
$(eval $(call BuildPackage,python-django-appconf-src))

$(eval $(call Py3Package,python3-django-appconf))
$(eval $(call BuildPackage,python3-django-appconf))
$(eval $(call BuildPackage,python3-django-appconf-src))
