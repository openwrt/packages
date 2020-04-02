#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-openpyxl
PKG_VERSION:=2.6.2
PKG_RELEASE:=1

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENCE.rst

PYPI_NAME:=openpyxl
PKG_HASH:=1d2af392cef8c8227bd2ac3ebe3a28b25aba74fd4fa473ce106065f0b73bfe2e

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python-openpyxl/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A Python library to read/write Excel 2010 xlsx/xlsm files
  URL:=https://openpyxl.readthedocs.org/
endef

define Package/python3-openpyxl
  $(call Package/python-openpyxl/Default)
  DEPENDS:= \
	+PACKAGE_python3-openpyxl:python3 \
	+PACKAGE_python3-openpyxl:python3-defusedxml \
	+PACKAGE_python3-openpyxl:python3-et_xmlfile \
	+PACKAGE_python3-openpyxl:python3-jdcal
  VARIANT:=python3
endef

define Package/python3-openpyxl/description
  A Python library to read/write Excel 2010 xlsx/xlsm files
.
(Variant for Python3)
endef

$(eval $(call Py3Package,python3-openpyxl))
$(eval $(call BuildPackage,python3-openpyxl))
$(eval $(call BuildPackage,python3-openpyxl-src))
