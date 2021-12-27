#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-restframework
PKG_VERSION:=3.13.1
PKG_RELEASE:=$(AUTORELEASE)

PYPI_NAME:=djangorestframework
PKG_HASH:=0c33407ce23acc68eca2a6e46424b008c9c02eceb8cf18581921d0092bc1f2ee

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.md

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-django-restframework
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Web APIs for Django, made easy.
  URL:=https://www.django-rest-framework.org
  DEPENDS:=+python3 +django
endef

define Package/python3-django-restframework/description
  Web APIs for Django, made easy.
endef

$(eval $(call Py3Package,python3-django-restframework))
$(eval $(call BuildPackage,python3-django-restframework))
$(eval $(call BuildPackage,python3-django-restframework-src))
