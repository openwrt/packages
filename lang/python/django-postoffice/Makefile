#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-postoffice
PKG_VERSION:=3.2.1
PKG_RELEASE:=1

PYPI_NAME:=django-post-office
PYPI_SOURCE_NAME:=django-post_office
PKG_HASH:=e32427822f647719575094f790ca949ef9f9827ec0e8378cb021f01f3834b2a4

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/django-postoffice/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A Django app to monitor and send mail asynchronously
  URL:=https://github.com/ui/django-post_office
endef

define Package/python-django-postoffice
$(call Package/django-postoffice/Default)
  DEPENDS:= \
	+PACKAGE_python-django-postoffice:python \
	python-django1 \
	+PACKAGE_python-django-postoffice:python-django-jsonfield
  VARIANT:=python
  MDEPENDS:=python-django1
endef

define Package/python-django-postoffice/description
  A Django app to monitor and send mail asynchronously, complete with template
  support
endef

define Package/python3-django-postoffice
$(call Package/django-postoffice/Default)
  DEPENDS:= \
	+PACKAGE_python3-django-postoffice:python3 \
	+PACKAGE_python3-django-postoffice:python3-django1 \
	+PACKAGE_python3-django-postoffice:python3-django-jsonfield
  VARIANT:=python3
endef

define Package/python3-django-postoffice/description
$(call Package/python-django-postoffice/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-django-postoffice))
$(eval $(call BuildPackage,python-django-postoffice))
$(eval $(call BuildPackage,python-django-postoffice-src))

$(eval $(call Py3Package,python3-django-postoffice))
$(eval $(call BuildPackage,python3-django-postoffice))
$(eval $(call BuildPackage,python3-django-postoffice-src))
