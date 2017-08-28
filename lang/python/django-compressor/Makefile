#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-compressor
PKG_VERSION:=2.1.1
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=django_compressor-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/38/58/03098a826062b856956c7169a8f778ec2b8e2767ddc63da0629062df5621/
PKG_BUILD_DIR:=$(BUILD_DIR)/django_compressor-$(PKG_VERSION)/
PKG_HASH:=9200400046ee00a5c1b4e2fbab97704fd2514f9b59d5649c8a365c3cf06c82e8
PKG_BUILD_DEPENDS:=python python-setuptools

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/django-compressor
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=Compresses linked and inline JavaScript or CSS into single cached files.
  URL:=http://django-compressor.readthedocs.org/
  DEPENDS:=+python +django
endef

define Package/django-compressor/description
  Compresses linked and inline JavaScript or CSS into single cached files.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/django-compressor/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,django-compressor))
