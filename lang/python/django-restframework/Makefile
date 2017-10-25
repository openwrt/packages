#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-restframework
PKG_VERSION:=3.5.4
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=djangorestframework-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/e9/24/86dfe19fb82a40a3d7a4c50371a8bd85b9277d3506698bf332a6d41d08f6/
PKG_BUILD_DIR:=$(BUILD_DIR)/djangorestframework-$(PKG_VERSION)
PKG_HASH:=f995a35ae22f354d2a9a42ee6d2c059c101f826b1485ed46781677895ad25ee5
PKG_BUILD_DEPENDS:=python python-setuptools

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

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
