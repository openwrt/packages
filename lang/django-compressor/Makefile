#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-compressor
PKG_VERSION:=2.1
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=django_compressor-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/23/46/2c7d582255969ad5259937f5f9e14aec1f3349d0fc0651129330918d1c6d/
PKG_BUILD_DIR:=$(BUILD_DIR)/django_compressor-$(PKG_VERSION)/
PKG_MD5SUM:=21ecfe4e8615eae64f7068a5599df9af
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
