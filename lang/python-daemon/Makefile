#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

SRC_PKG_NAME:=python-daemon
PKG_NAME:=$(SRC_PKG_NAME)
PKG_VERSION:=2.0.6
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0

PKG_SOURCE:=$(SRC_PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/p/$(SRC_PKG_NAME)
PKG_MD5SUM:=049508c47c8fa054e91ec9a3c572f939
PKG_SOURCE_DIR:=$(SRC_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_DIR)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

PKG_BUILD_DEPENDS:=python python-setuptools python-package-docutils

define Package/$(PKG_NAME)
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=PEP 3143 well-behaved daemon library for Python
	URL:=https://alioth.debian.org/projects/python-daemon
	MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
	DEPENDS:=+python +python-docutils +python-lockfile
endef

define Package/$(PKG_NAME)/description
 python-daemon implements PEP 3143 well-behaved daemon library for Python
endef

$(eval $(call PyMod/Default))
$(eval $(call BuildPackage,$(PKG_NAME)))
