#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-postoffice
PKG_VERSION:=2.0.8
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=django-post_office-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/52/25/cc0cfe923f183d7c19b162cac3bf8430ddaed7bad28202b8f93a97d248a4/
PKG_BUILD_DIR:=$(BUILD_DIR)/django-post_office-$(PKG_VERSION)/
PKG_MD5SUM:=437bf62cef06381d346ae2bc087c0e3c
PKG_BUILD_DEPENDS:=python python-setuptools

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/django-postoffice
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=A Django app to monitor and send mail asynchronously, complete with template support.
  URL:=https://github.com/ui/django-postoffice
  DEPENDS:=+python +django +django-jsonfield
endef

define Package/django-postoffice/description
  A Django app to monitor and send mail asynchronously, complete with template support.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/django-postoffice/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,django-postoffice))
