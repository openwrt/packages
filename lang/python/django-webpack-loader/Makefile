#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=django-webpack-loader
PKG_VERSION:=0.6.0
PKG_RELEASE:=2
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/d/${PKG_NAME}
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
  VARIANT:=python
endef

define Package/django-webpack-loader/description
  Use webpack to generate your static bundles without django’s staticfiles or opaque wrappers.
endef

$(eval $(call PyPackage,django-webpack-loader))
$(eval $(call BuildPackage,django-webpack-loader))
$(eval $(call BuildPackage,django-webpack-loader-src))
