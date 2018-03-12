#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-restframework
PKG_VERSION:=3.7.1
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=djangorestframework-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/d0/ab/8b991e7d3e26af7cf6327c84b341e60004fc56325d8a4d4019e1474f7456/
PKG_BUILD_DIR:=$(BUILD_DIR)/djangorestframework-$(PKG_VERSION)
PKG_HASH:=305b2c6564ca46d3b558ba21110ed717135c467adf1a6dfd192bd85f4bb04d50

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django-restframework
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=Web APIs for Django, made easy.
  URL:=http://www.django-rest-framework.org/
  DEPENDS:=+python +django
endef

define Package/django-restframework/description
  Web APIs for Django, made easy.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/django-restframework/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,django-restframework))
