#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=et_xmlfile
PKG_VERSION:=1.0.1
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://pypi.python.org/packages/source/e/et_xmlfile/
PKG_HASH:=614d9722d572f6246302c4491846d2c393c199cfa4edc9af593437691683335b

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/et_xmlfile
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=An implementation of lxml.xmlfile for the standard library
  URL:=https://bitbucket.org/openpyxl/et_xmlfile
  DEPENDS:=+python
endef

define Package/et_xmlfile/description
  An implementation of lxml.xmlfile for the standard library
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/et_xmlfile/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,et_xmlfile))
