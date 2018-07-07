#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pyjwt
PKG_VERSION:=1.6.4
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=PyJWT-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/00/5e/b358c9bb24421e6155799d995b4aa3aa3307ffc7ecae4ad9d29fd7e07a73
PKG_HASH:=4ee413b357d53fd3fb44704577afac88e72e878716116270d722723d65b42176
PKG_BUILD_DIR:=$(BUILD_DIR)/PyJWT-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/pyjwt
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
  TITLE:=JSON Web Token implementation in Python
  URL:=http://github.com/jpadilla/pyjwt
  DEPENDS:=+python
endef

define Package/pyjwt/description
  A Python implementation of RFC 7519.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/pyjwt/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,pyjwt))
