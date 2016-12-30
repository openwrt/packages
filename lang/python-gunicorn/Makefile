#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

SRC_PKG_NAME:=gunicorn
PKG_NAME:=python-$(SRC_PKG_NAME)
PKG_VERSION:=19.3.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(SRC_PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/g/$(SRC_PKG_NAME)
PKG_MD5SUM:=faa3e80661efd67e5e06bba32699af20
PKG_SOURCE_DIR:=$(SRC_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_DIR)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

PKG_BUILD_DEPENDS:=python python-setuptools

define Package/$(PKG_NAME)
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=WSGI HTTP server for Unix
	URL:=http://gunicorn.org
	MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
	DEPENDS:=+python
endef

define Package/$(PKG_NAME)/description
 gunicorn is a WGSI HTTP server for Python on Unix
endef

$(eval $(call PyMod/Default))
$(eval $(call BuildPackage,$(PKG_NAME)))
