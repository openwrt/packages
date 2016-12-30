#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-django
SRC_PKG_NAME:=Django
PKG_VERSION:=1.8.7
PKG_RELEASE=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(SRC_PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/D/$(SRC_PKG_NAME)
PKG_MD5SUM:=44c01355b5efa01938a89b8bd798b1ed
PKG_SOURCE_DIR:=$(SRC_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_DIR)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

PKG_BUILD_DEPENDS:=python python-setuptools

define Package/$(PKG_NAME)
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=Django web application framework for Python
	URL:=https://www.djangoproject.com
	MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
	DEPENDS:=+python
endef

define Package/$(PKG_NAME)/description
 Django is a web application framework written in Python
 This packages installs the LTS version.
endef

$(eval $(call PyMod/Default))
$(eval $(call BuildPackage,$(PKG_NAME)))
