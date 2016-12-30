#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

SRC_PKG_NAME:=Pillow
PKG_NAME:=python-package-pillow
PKG_VERSION:=2.9.0
PKG_RELEASE:=1
PKG_LICENSE_FILE:=LICENSE

PKG_SOURCE:=$(SRC_PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/P/$(SRC_PKG_NAME)
PKG_MD5SUM:=46f1729ece27981d54ec543ad5b37d14
PKG_SOURCE_DIR:=$(SRC_PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_DIR)

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

PKG_BUILD_DEPENDS:=python python-setuptools

define Package/$(PKG_NAME)
	SUBMENU:=Python
	SECTION:=lang
	CATEGORY:=Languages
	TITLE:=Fork of Python Imaging Library
	URL:=http://python-pillow.github.io
	MAINTAINER:=Daniel Dickinson <openwrt@daniel.thecshore.com>
	DEPENDS:=+python +zlib +libjpeg +libfreetype +libtiff
endef

define Package/$(PKG_NAME)/description
 Pillow is a for of PIL - an imaging library for Python
endef

$(eval $(call PyMod/Default,$(SRC_PKG_NAME),PIL))

define Build/Compile
	$(CP) ./files/setup.cfg $(PKG_BUILD_DIR)/
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR),INCLUDE=$(STAGING_DIR)/usr/include LD_RUN_PATH=$(STAGING_DIR)/usr/lib)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
