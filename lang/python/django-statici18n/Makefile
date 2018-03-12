#
# Copyright (C) 2007-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-statici18n
PKG_VERSION:=1.6.1
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/0a/24/1bed254529fc492ee5daf4cba18cf188b059866049889ecf1f178f25a2c2/
PKG_HASH:=47d30939d52bcbbf1cbfe56b786bc2f2ea874266a8315cb027c061f320c4e2f6

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django-statici18n
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=A Django app that provides helper for generating JavaScript catalog to static files.
  URL:=http://django-statici18n.readthedocs.org/
  DEPENDS:=+python +django
endef

define Package/django-statici18n/description
  A Django app that provides helper for generating JavaScript catalog to static files.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/django-statici18n/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,django-statici18n))
