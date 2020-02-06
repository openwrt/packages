#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-picklefield
PKG_VERSION:=1.1.0
PKG_RELEASE:=4

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=ce7fee5c6558fe5dc8924993d994ccde75bb75b91cd82787cbd4c92b95a69f9c

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/django-picklefield/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Pickled object field for Django
  URL:=https://github.com/gintas/django-picklefield/
endef

define Package/python-django-picklefield
$(call Package/django-picklefield/Default)
  DEPENDS:= \
	+PACKAGE_python-django-picklefield:python \
	python-django1
  VARIANT:=python
  MDEPENDS:=python-django1
endef

define Package/python-django-picklefield/description
  Pickled object field for Django
endef

define Package/python3-django-picklefield
$(call Package/django-picklefield/Default)
  DEPENDS:= \
	+PACKAGE_python3-django-picklefield:python3 \
	python3-django
  VARIANT:=python3
  MDEPENDS:=python3-django
endef

define Package/python3-django-picklefield/description
$(call Package/python-django-picklefield/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-django-picklefield))
$(eval $(call BuildPackage,python-django-picklefield))
$(eval $(call BuildPackage,python-django-picklefield-src))

$(eval $(call Py3Package,python3-django-picklefield))
$(eval $(call BuildPackage,python3-django-picklefield))
$(eval $(call BuildPackage,python3-django-picklefield-src))
