#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-crcmod
PKG_VERSION:=1.7
PKG_RELEASE:=1
PKG_MAINTAINER:=Micke Prag <micke.prag@telldus.se>
PKG_LICENSE:=MIT

PKG_SOURCE:=crcmod-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://pypi.python.org/packages/source/c/crcmod/
PKG_HASH:=dc7051a0db5f2bd48665a990d3ec1cc305a466a77358ca4492826f41f283601e

PKG_BUILD_DIR:=$(BUILD_DIR)/crcmod-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=python

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-crcmod
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=python-crcmod
  URL:=http://crcmod.sourceforge.net/
  DEPENDS:=+python-light
endef

define Package/python-crcmod/description
  The software in this package is a Python module for generating objects that compute the Cyclic Redundancy Check (CRC). There is no attempt in this package to explain how the CRC works. There are a number of resources on the web that give a good explanation of the algorithms. Just do a Google search for "crc calculation" and browse till you find what you need. Another resource can be found in chapter 20 of the book "Numerical Recipes in C" by Press et. al.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix="$(PKG_INSTALL_DIR)/usr")
endef

define Package/python-crcmod/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,python-crcmod))
