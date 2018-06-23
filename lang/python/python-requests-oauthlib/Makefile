#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-requests-oauthlib
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=ISC

PKG_SOURCE:=requests-oauthlib-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/95/be/072464f05b70e4142cb37151e215a2037b08b1400f8a56f2538b76ca6205
PKG_HASH:=8886bfec5ad7afb391ed5443b1f697c6f4ae98d0e5620839d8b4499c032ada3f
PKG_BUILD_DIR:=$(BUILD_DIR)/requests-oauthlib-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-requests-oauthlib
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
  TITLE:=OAuthlib authentication support for Requests.
  URL:=https://github.com/requests/requests-oauthlib
  DEPENDS:=+python +python-requests +python-oauthlib +python-cryptography +pyjwt
endef

define Package/python-requests-oauthlib/description
  This project provides first-class OAuth library support for Requests.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/python-requests-oauthlib/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,python-requests-oauthlib))
