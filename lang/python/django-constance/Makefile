#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-constance
PKG_VERSION:=2.3.1
PKG_RELEASE:=3
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/django-constance
PKG_HASH:=a49735063b2c30015d2e52a90609ea9798da722ed070f091de51714758a5d018
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-django-constance-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

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
	python-django
  VARIANT:=python
  MDEPENDS:=python-django
endef

define Package/python-django-constance/description
  Django live settings with pluggable backends, including Redis.
endef

define Package/python3-django-constance
$(call Package/python-django-constance/Default)
  DEPENDS:= \
	+PACKAGE_python3-django-constance:python3 \
	python3-django
  VARIANT:=python3
  MDEPENDS:=python3-django
endef

define Package/python3-django-constance/description
$(call define Package/python-django-constance/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-django-constance))
$(eval $(call BuildPackage,python-django-constance))
$(eval $(call Py3Package,python3-django-constance))
$(eval $(call BuildPackage,python3-django-constance))
