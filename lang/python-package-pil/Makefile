#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

SRC_PKG_NAME:=PIL
PKG_NAME:=python-package-pil
PKG_VERSION:=1.1.7
PKG_RELEASE:=1
PKG_LICENSE_FILE:=README

PKG_SOURCE:=$(SRC_PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://effbot.org/media/downloads
PKG_MD5SUM:=a4f6ff4fe9490171910ad1585aef85b5
PKG_SOURCE_DIR:=$(SRC_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_DIR)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

PKG_BUILD_DEPENDS:=python python-setuptools

define Package/$(PKG_NAME)
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=Python Imaging Library
	URL:=http://www.pythonware.com/products/pil
	MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
	DEPENDS:=+python +zlib +libjpeg +libfreetype
endef

define Package/$(PKG_NAME)/description
 PIL is an imaging library for Python
endef

$(eval $(call PyMod/Default,$(SRC_PKG_NAME),))
$(eval $(call BuildPackage,$(PKG_NAME)))
