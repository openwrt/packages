#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-formtools
PKG_VERSION:=2.1
PKG_RELEASE:=2
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/${PKG_NAME}
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
  VARIANT:=python
endef

define Package/django-formtools/description
  Django "formtools" is a set of high-level abstractions for Django forms.
  Currently for form previews and multi-step forms.
endef

$(eval $(call PyPackage,django-formtools))
$(eval $(call BuildPackage,django-formtools))
$(eval $(call BuildPackage,django-formtools-src))
