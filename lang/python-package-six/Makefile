#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

SRC_PKG_NAME:=six
PKG_NAME:=python-package-$(SRC_PKG_NAME)
PKG_VERSION:=1.9.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(SRC_PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/s/$(SRC_PKG_NAME)
PKG_MD5SUM:=476881ef4012262dfc8adc645ee786c4
PKG_SOURCE_DIR:=$(SRC_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_DIR)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

PKG_BUILD_DEPENDS:=python python-setuptools

define Package/$(PKG_NAME)
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=Python 2 and 3 compatibility library for Python
	URL:=http://pypi.python.org/pypi/six
	MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
	DEPENDS:=+python
endef

define Package/$(PKG_NAME)/description
 six is a Python 2 and 3 compatibility library for Python
endef

$(eval $(call PyMod/Default,$(SRC_PKG_NAME),))
$(eval $(call BuildPackage,$(PKG_NAME)))
