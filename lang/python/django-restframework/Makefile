#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-restframework
PKG_VERSION:=3.18.3
PKG_RELEASE:=1

PYPI_NAME:=djangorestframework
PKG_HASH:=446a9b352e7eff630421ab3f2328bd2401b109a9470afa4a31189994911ed030

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.md
PKG_CPE_ID:=cpe:/a:django-rest-framework:django_rest_framework

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
