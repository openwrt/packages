#
# Copyright (C) Alexandru Ardelean <ardeleanalex@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django1
PKG_VERSION:=1.11.29
PKG_RELEASE:=2

PYPI_NAME:=Django
PKG_HASH:=4200aefb6678019a0acf0005cd14cfce3a5e6b9b90d06145fcdd2e474ad4329c

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE LICENSE.python
PKG_CPE_ID:=cpe:/a:djangoproject:django

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/django1/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=The web framework for perfectionists with deadlines.
  URL:=https://www.djangoproject.com/
endef

define Package/python-django1
$(call Package/django1/Default)
  DEPENDS:= \
	+PACKAGE_python-django1:python \
	+PACKAGE_python-django1:python-pytz \
	+PACKAGE_python-django1:python-django1-common
  VARIANT:=python
  MENU:=1
endef

define Package/python-django1/description
  The web framework for perfectionists with deadlines (LTS 1.11 series).
endef

define Package/python3-django1
$(call Package/django1/Default)
  DEPENDS:= \
	+PACKAGE_python3-django1:python3 \
	+PACKAGE_python3-django1:python3-pytz \
	+PACKAGE_python3-django1:python-django1-common
  VARIANT:=python3
  PROVIDES:=django
endef

define Package/python3-django1/description
$(call Package/python-django1/description)
.
(Variant for Python3)
endef

define Package/python-django1-common
$(call Package/django1/Default)
endef

define Package/python-django1-common/description
$(call Package/python-django1/description)
.
This package contains files common to both Python 2.7 and Python 3.
endef

PyPackage/python-django1/install:=:
Py3Package/python3-django1/install:=:

define Package/python-django1-common/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/django-admin $(1)/usr/bin
endef

$(eval $(call PyPackage,python-django1))
$(eval $(call BuildPackage,python-django1))
$(eval $(call BuildPackage,python-django1-src))

$(eval $(call Py3Package,python3-django1))
$(eval $(call BuildPackage,python3-django1))
$(eval $(call BuildPackage,python3-django1-src))

$(eval $(call BuildPackage,python-django1-common))
