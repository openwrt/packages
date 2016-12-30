#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

SRC_PKG_NAME:=chardet
PKG_NAME:=python-$(SRC_PKG_NAME)
PKG_VERSION:=2.3.0
PKG_RELEASE:=1
PKG_LICENSE:=LGPL-2.1

PKG_SOURCE:=$(SRC_PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/c/$(SRC_PKG_NAME)
PKG_MD5SUM:=25274d664ccb5130adae08047416e1a8
PKG_SOURCE_DIR:=$(SRC_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_DIR)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

PKG_BUILD_DEPENDS:=python python-setuptools

define Package/$(PKG_NAME)
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=Universal character encoding detector for Python
	URL:=https://github.com/chardet/chardet
	MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
	DEPENDS:=+python
endef

define Package/$(PKG_NAME)/description
 chardet is a python module detects character encodings
endef

$(eval $(call PyMod/Default))
$(eval $(call BuildPackage,$(PKG_NAME)))
