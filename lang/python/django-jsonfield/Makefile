#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-jsonfield
PKG_VERSION:=1.0.1
PKG_RELEASE:=5

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=6c0afd5554739365b55d86e285cf966cc3a45682fff963463364ea1f6511ca3e

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/django-jsonfield/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=JSONField for django models
  URL:=https://github.com/adamchainz/django-jsonfield
endef

define Package/python-django-jsonfield
$(call Package/django-jsonfield/Default)
  DEPENDS:= \
	+PACKAGE_python-django-jsonfield:python \
	python-django1
  VARIANT:=python
  MDEPENDS:=python-django1
endef

define Package/python-django-jsonfield/description
  JSONField for django models
endef

define Package/python3-django-jsonfield
$(call Package/django-jsonfield/Default)
  DEPENDS:= \
	+PACKAGE_python3-django-jsonfield:python3 \
	python3-django
  VARIANT:=python3
  MDEPENDS:=python3-django
endef

define Package/python3-django-jsonfield/description
$(call Package/python-django-jsonfield/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-django-jsonfield))
$(eval $(call BuildPackage,python-django-jsonfield))
$(eval $(call BuildPackage,python-django-jsonfield-src))

$(eval $(call Py3Package,python3-django-jsonfield))
$(eval $(call BuildPackage,python3-django-jsonfield))
$(eval $(call BuildPackage,python3-django-jsonfield-src))
