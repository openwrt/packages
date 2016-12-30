#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

SRC_PKG_NAME:=python-dateutil
PKG_NAME:=python-package-$(SRC_PKG_NAME)
PKG_VERSION:=2.4.2
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(SRC_PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/p/$(SRC_PKG_NAME)
PKG_MD5SUM:=4ef68e1c485b09e9f034e10473e5add2
PKG_SOURCE_DIR:=$(SRC_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_DIR)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

PKG_BUILD_DEPENDS:=python python-setuptools

define Package/$(PKG_NAME)
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=Extension to datetime module for Python
	URL:=https://github.com/chardet/chardet
	MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
	DEPENDS:=+python +python-package-six
endef

define Package/$(PKG_NAME)/description
 python-dateutil is a power extension to datetime module for Python
endef

$(eval $(call PyMod/Default,$(SRC_PKG_NAME),dateutil))
$(eval $(call BuildPackage,$(PKG_NAME)))
