#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-picklefield
PKG_VERSION:=2.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/django-picklefield
PKG_HASH:=f1733a8db1b6046c0d7d738e785f9875aa3c198215de11993463a9339aa4ea24

PKG_BUILD_DEPENDS:=python/host pytz/host

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django-picklefield
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=Pickled object field for Django
  URL:=https://github.com/gintas/django-picklefield
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
