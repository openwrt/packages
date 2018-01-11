#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openpyxl
PKG_VERSION:=2.5.0b1
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/88/3c/34fbe561fc92e6a75f297478b123c2590ca986d9f2d2dbf340d879aa24dd/
PKG_HASH:=3b42ece7933b46b2128f8d4111c57c80fb5aa46f4d16e7f83281f169e7398ba7

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/openpyxl
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=A Python library to read/write Excel 2010 xlsx/xlsm files
  URL:=https://openpyxl.readthedocs.org/
  DEPENDS:=+python +django
endef

define Package/openpyxl/description
  A Python library to read/write Excel 2010 xlsx/xlsm files
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/openpyxl/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,openpyxl))
