#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-picklefield
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/e8/69/232d78ef16cad8dd4c2f871b0f44d87bcde36ed6a90597416e903034600b/
PKG_HASH:=61e3ba7f6df82d8df9e6be3a8c55ef589eb3bf926c3d25d2b7949b07eae78354

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django-picklefield
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=Pickled object field for Django
  URL:=http://github.com/gintas/django-picklefield/
  DEPENDS:=+python +django
endef

define Package/django-picklefield/description
  Pickled object field for Django
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/django-picklefield/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,django-picklefield))
