#
# Copyright (C) 2019 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyparsing
PKG_VERSION:=2.4.0
PKG_RELEASE:=1

PKG_SOURCE:=pyparsing-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pyparsing/
PKG_HASH:=1873c03321fc118f4e9746baf201ff990ceb915f433f23b395f5580d1840cb2a
PKG_BUILD_DIR:=$(BUILD_DIR)/pyparsing-$(PKG_VERSION)

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pyparsing
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Library for constructing grammar directly in python
  URL:=https://github.com/pyparsing/pyparsing/
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python3-pyparsing/description
  The pyparsing module is an alternative approach to creating
  and executing simple grammars, vs. the traditional lex/yacc
  approach, or the use of regular expressions.
  The pyparsing module provides a library of classes that
  client code uses to construct the grammar directly in Python code.
endef

$(eval $(call Py3Package,python3-pyparsing))
$(eval $(call BuildPackage,python3-pyparsing))
$(eval $(call BuildPackage,python3-pyparsing-src))
