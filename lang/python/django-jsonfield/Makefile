#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-jsonfield
PKG_VERSION:=2.1.1
PKG_RELEASE:=1

PYPI_NAME:=jsonfield
PKG_HASH:=ed7c5e1829e9453e24a8bebef1e702ffe402e6def6b326f0e0b88764c59a6dc7

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/django-jsonfield/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A reusable Django field to store validated JSON in models
  URL:=https://github.com/rpkilby/jsonfield
endef

define Package/python-django-jsonfield
$(call Package/django-jsonfield/Default)
  DEPENDS:= \
	+PACKAGE_python-django-jsonfield:python \
	python-django1 \
	+PACKAGE_python-django-jsonfield:python-six
  VARIANT:=python
  MDEPENDS:=python-django1
endef

define Package/python-django-jsonfield/description
  jsonfield is a reusable model field that allows you to store validated
  JSON, automatically handling serialization to and from the database.
endef

define Package/python3-django-jsonfield
$(call Package/django-jsonfield/Default)
  DEPENDS:= \
	+PACKAGE_python3-django-jsonfield:python3 \
	+PACKAGE_python3-django-jsonfield:python3-django1 \
	+PACKAGE_python3-django-jsonfield:python3-six
  VARIANT:=python3
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
