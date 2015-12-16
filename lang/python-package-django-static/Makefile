#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

SRC_PKG_NAME:=django-static
PKG_NAME:=python-package-$(SRC_PKG_NAME)
PKG_VERSION:=1.5.5
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(SRC_PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/d/$(SRC_PKG_NAME)
PKG_MD5SUM:=2db80302ace2ea3bbec30c111a68d3ca
PKG_SOURCE_DIR:=$(SRC_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_DIR)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

PKG_BUILD_DEPENDS:=python python-setuptools

define Package/$(PKG_NAME)
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=Template tags for static content in Django
	URL:=http://github.com/peterbe/django-static
	MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
	DEPENDS:=+python
endef

define Package/$(PKG_NAME)/description
 django-static enables template tags for better serving static content
 in Django apps (e.g. for serving the static content outside Django).
endef

$(eval $(call PyMod/Default,$(SRC_PKG_NAME),))
$(eval $(call BuildPackage,$(PKG_NAME)))
