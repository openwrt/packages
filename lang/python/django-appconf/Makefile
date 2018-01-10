#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-appconf
PKG_VERSION:=1.0.2
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/34/b9/d07195652ab494b026f7cb0341dd6e5f2e6e39be177abe05e2cec8bd46e4/
PKG_HASH:=6a4d9aea683b4c224d97ab8ee11ad2d29a37072c0c6c509896dd9857466fb261

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

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
