#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-openpyxl
PKG_VERSION:=3.0.9
PKG_RELEASE:=$(AUTORELEASE)

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENCE.rst

PYPI_NAME:=openpyxl
PKG_HASH:=40f568b9829bf9e446acfffce30250ac1fa39035124d55fc024025c41481c90f

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-openpyxl
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A Python library to read/write Excel 2010 xlsx/xlsm files
  URL:=https://openpyxl.readthedocs.org/
  DEPENDS:=+python3 +python3-defusedxml +python3-et_xmlfile +python3-jdcal
endef

define Package/python3-openpyxl/description
  A Python library to read/write Excel 2010 xlsx/xlsm files
endef

$(eval $(call Py3Package,python3-openpyxl))
$(eval $(call BuildPackage,python3-openpyxl))
$(eval $(call BuildPackage,python3-openpyxl-src))
