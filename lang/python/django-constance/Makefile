#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-constance
PKG_VERSION:=2.3.1
PKG_RELEASE:=5

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=a49735063b2c30015d2e52a90609ea9798da722ed070f091de51714758a5d018

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=BSD-3-Clause

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-django-constance/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Django live settings with pluggable backends, including Redis.
  URL:=https://github.com/jazzband/django-constance
endef

define Package/python-django-constance
$(call Package/python-django-constance/Default)
  DEPENDS:= \
	+PACKAGE_python-django-constance:python \
	python-django1
  VARIANT:=python
  MDEPENDS:=python-django1
endef

define Package/python-django-constance/description
  Django live settings with pluggable backends, including Redis.
endef

define Package/python3-django-constance
$(call Package/python-django-constance/Default)
  DEPENDS:= \
	+PACKAGE_python3-django-constance:python3 \
	+PACKAGE_python3-django-constance:python3-django1
  VARIANT:=python3
endef

define Package/python3-django-constance/description
$(call Package/python-django-constance/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-django-constance))
$(eval $(call BuildPackage,python-django-constance))
$(eval $(call BuildPackage,python-django-constance-src))

$(eval $(call Py3Package,python3-django-constance))
$(eval $(call BuildPackage,python3-django-constance))
$(eval $(call BuildPackage,python3-django-constance-src))
