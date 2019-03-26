#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-jsonfield
PKG_VERSION:=1.0.1
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/e4/b2/a079f0a2218e0eb7892edbf404e0bbfbb281a6bbf06966b775f5142ed159/
PKG_HASH:=6c0afd5554739365b55d86e285cf966cc3a45682fff963463364ea1f6511ca3e

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django-jsonfield
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=JSONField for django models
  URL:=https://github.com/bradjasper/django-jsonfield
  DEPENDS:=+python +django
endef

define Package/django-jsonfield/description
  JSONField for django models
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/django-jsonfield/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,django-jsonfield))
