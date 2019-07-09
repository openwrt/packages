#
# Copyright (C) 2007-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-statici18n
PKG_VERSION:=1.8.2
PKG_RELEASE:=3
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/django-statici18n
PKG_HASH:=ba9eeb3c4517027922645999359f8335fbb9fea04c457123cfbd6b4a36cbeda4
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django-statici18n
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
<<<<<<< HEAD
  TITLE:=A Django app that provides helper for generating JavaScript catalog to static files.
  URL:=https://django-statici18n.readthedocs.org/
  DEPENDS:=+python +python-django
=======
  TITLE:=Helper for generating JavaScript catalog to static files
  URL:=https://$(PKG_NAME).readthedocs.io
endef

define Package/python-$(PKG_NAME)
$(call Package/$(PKG_NAME)/Default)
  DEPENDS:= \
	+PACKAGE_python-$(PKG_NAME):python \
	python-django
  VARIANT:=python
  MDEPENDS:=python-django
>>>>>>> 90527d75a... django: move django* packages under django submenu
endef

define Package/django-statici18n/description
  A Django app that provides helper for generating JavaScript catalog to static files.
endef

<<<<<<< HEAD
define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
=======
define Package/python3-$(PKG_NAME)
$(call Package/$(PKG_NAME)/Default)
  DEPENDS:= \
	+PACKAGE_python3-$(PKG_NAME):python3 \
	python3-django
  VARIANT:=python3
  MDEPENDS:=python3-django
>>>>>>> 90527d75a... django: move django* packages under django submenu
endef

define Package/django-statici18n/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,django-statici18n))
