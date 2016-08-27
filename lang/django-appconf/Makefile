#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-appconf
PKG_VERSION:=1.0.1
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://pypi.python.org/packages/source/d/django-appconf/
PKG_MD5SUM:=29c87a00f0d098b90f3ac6113ae6e52d
PKG_BUILD_DEPENDS:=python python-setuptools

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/django-appconf
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=A helper class for handling configuration defaults of packaged apps gracefully.
  URL:=http://django-appconf.readthedocs.org/
  DEPENDS:=+python +django
endef

define Package/django-appconf/description
  A helper class for handling configuration defaults of packaged apps gracefully.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/django-appconf/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,django-appconf))
