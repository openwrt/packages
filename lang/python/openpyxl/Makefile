#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openpyxl
PKG_VERSION:=2.5.8
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/o/openpyxl
PKG_HASH:=22904d7bdfaaab33d65d50a0915a65eeb2f29c85d9ec53081563850678a29927

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
