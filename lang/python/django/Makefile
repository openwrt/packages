#
# Copyright (C) Alexandru Ardelean <ardeleanalex@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django
PKG_VERSION:=2.2.6
PKG_RELEASE:=1

PYPI_NAME:=Django
PKG_HASH:=a8ca1033acac9f33995eb2209a6bf18a4681c3e5269a878e9a7e0b7384ed1ca3

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE LICENSE.python
PKG_CPE_ID:=cpe:/a:djangoproject:django

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/django/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=The web framework for perfectionists with deadlines.
  URL:=https://www.djangoproject.com/
  MENU:=1
endef

define Package/python3-django
$(call Package/django/Default)
  DEPENDS:= \
	+PACKAGE_python3-django:python3 \
	+PACKAGE_python3-django:python3-pytz
  VARIANT:=python3
endef

define Package/python3-django/description
    The web framework for perfectionists with deadlines (LTS 2.2 series).
    Python3 only.
endef

$(eval $(call Py3Package,python3-django))
$(eval $(call BuildPackage,python3-django))
$(eval $(call BuildPackage,python3-django-src))
