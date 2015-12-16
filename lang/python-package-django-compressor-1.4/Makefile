#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-package-django-compressor-1.4
SRC_PKG_NAME:=django-compressor
PKG_VERSION:=1.4
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/django-compressor/django-compressor
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=e747dce3d7e04fe595bbfed54f9554c2725eb757
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

PKG_BUILD_DEPENDS:=python python-setuptools

define Package/$(PKG_NAME)
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=Asset compression for Django
	URL:=http://django-compressor.readthedocs.org/en/latest/
	MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
	DEPENDS:=+python +python-package-django-1.5 +python-package-django-appconf
	PROVIDES:=django-compressor
endef

define Package/$(PKG_NAME)/description
 django-compressor is a python module for compressing web assets when
 using Django web application framework.
endef

$(eval $(call PyMod/Default,$(SRC_PKG_NAME),))
$(eval $(call BuildPackage,$(PKG_NAME)))
