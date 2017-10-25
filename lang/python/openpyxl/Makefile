#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openpyxl
PKG_VERSION:=2.4.2
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/56/c6/a2a7c36196e4732acceca093ce5961db907f5a855b557d6a727a7f59b8b4/
PKG_HASH:=2fe9ba182b687acf7e4660b39bd91d703c0bf934f8295c182d04ecd2345c6e26
PKG_BUILD_DEPENDS:=python python-setuptools

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

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
