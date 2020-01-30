#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-restframework
PKG_VERSION:=3.9.0
PKG_RELEASE:=5

PYPI_NAME:=djangorestframework
PKG_HASH:=607865b0bb1598b153793892101d881466bd5a991de12bd6229abb18b1c86136

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.md

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/django-restframework/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Web APIs for Django, made easy.
  URL:=https://www.django-rest-framework.org
endef

define Package/python-django-restframework
$(call Package/django-restframework/Default)
  DEPENDS:= \
	+PACKAGE_python-django-restframework:python \
	python-django1
  VARIANT:=python
  MDEPENDS:=python-django1
endef

define Package/python-django-restframework/description
  Web APIs for Django, made easy.
endef

define Package/python3-django-restframework
$(call Package/django-restframework/Default)
  DEPENDS:= \
	+PACKAGE_python3-django-restframework:python3 \
	python3-django
  VARIANT:=python3
  MDEPENDS:=python3-django
endef

define Package/python3-django-restframework/description
$(call Package/python-django-restframework/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-django-restframework))
$(eval $(call BuildPackage,python-django-restframework))
$(eval $(call BuildPackage,python-django-restframework-src))

$(eval $(call Py3Package,python3-django-restframework))
$(eval $(call BuildPackage,python3-django-restframework))
$(eval $(call BuildPackage,python3-django-restframework-src))
