#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-formtools
PKG_VERSION:=2.1
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/4a/86/ccbb8225dec0621f99f7e19f3dea0a629f1e41bd99fd58ac3e2f388e028f
PKG_HASH:=7703793f1675aa6e871f9fed147e8563816d7a5b9affdc5e3459899596217f7c

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django-formtools
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
  TITLE:=A set of high-level abstractions for Django forms
  URL:=https://django-formtools.readthedocs.io/en/latest/
  DEPENDS:=+python +django
endef

define Package/django-formtools/description
  Django "formtools" is a set of high-level abstractions for Django forms.
  Currently for form previews and multi-step forms.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/django-formtools/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,django-formtools))
