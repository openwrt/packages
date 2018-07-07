#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-webpack-loader
PKG_VERSION:=0.6.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/ff/0f/e812908c5dcc7c8cac5beba2cddd14bbfe045496117b3d306a71b19fc828
PKG_HASH:=60bab6b9a037a5346fad12d2a70a6bc046afb33154cf75ed640b93d3ebd5f520

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/django-webpack-loader
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
  TITLE:=Transparently use webpack with django
  URL:=https://github.com/owais/django-webpack-loader
  DEPENDS:=+python +django
endef

define Package/django-webpack-loader/description
  Use webpack to generate your static bundles without django’s staticfiles or opaque wrappers.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/django-webpack-loader/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,django-webpack-loader))
