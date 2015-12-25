#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

SRC_PKG_NAME:=flup
PKG_NAME:=python-$(SRC_PKG_NAME)
PKG_VERSION:=1.0.2
PKG_RELEASE:=1
PKG_LICENSE:=BSD-2-Clause

PKG_SOURCE:=$(SRC_PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/f/$(SRC_PKG_NAME)
PKG_MD5SUM:=24dad7edc5ada31dddd49456ee8d5254
PKG_SOURCE_DIR:=$(SRC_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_DIR)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

PKG_BUILD_DEPENDS:=python python-setuptools

define Package/$(PKG_NAME)
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=WSGI servers for Python
	URL:=http://www.saddi.com/software/flup/
	MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
	DEPENDS:=+python
endef

define Package/$(PKG_NAME)/description
 A random assortment of WGSI servers
endef

$(eval $(call PyMod/Default))
$(eval $(call BuildPackage,$(PKG_NAME)))
