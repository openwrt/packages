#
# Copyright (C) 2007-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-statici18n
PKG_VERSION:=1.8.2
PKG_RELEASE:=6

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=ba9eeb3c4517027922645999359f8335fbb9fea04c457123cfbd6b4a36cbeda4

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/django-statici18n/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Helper for generating JavaScript catalog to static files
  URL:=https://django-statici18n.readthedocs.io
endef

define Package/python-django-statici18n
$(call Package/django-statici18n/Default)
  DEPENDS:= \
	+PACKAGE_python-django-statici18n:python \
	python-django1
  VARIANT:=python
  MDEPENDS:=python-django1
endef

define Package/python-django-statici18n/description
  A Django app that provides helper for generating JavaScript catalog to static files.
endef

define Package/python3-django-statici18n
$(call Package/django-statici18n/Default)
  DEPENDS:= \
	+PACKAGE_python3-django-statici18n:python3 \
	+PACKAGE_python3-django-statici18n:python3-django1
  VARIANT:=python3
endef

define Package/python3-django-statici18n/description
$(call Package/python-django-statici18n/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-django-statici18n))
$(eval $(call BuildPackage,python-django-statici18n))
$(eval $(call BuildPackage,python-django-statici18n-src))

$(eval $(call Py3Package,python3-django-statici18n))
$(eval $(call BuildPackage,python3-django-statici18n))
$(eval $(call BuildPackage,python3-django-statici18n-src))
