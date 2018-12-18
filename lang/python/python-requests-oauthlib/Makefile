#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-requests-oauthlib
PKG_VERSION:=1.0.0
PKG_RELEASE:=2
PKG_LICENSE:=ISC

PKG_SOURCE:=requests-oauthlib-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/r/requests-oauthlib
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
  DEPENDS:=+python +python-requests +python-oauthlib +python-cryptography +python-pyjwt
  VARIANT:=python
endef

define Package/python-requests-oauthlib/description
  This project provides first-class OAuth library support for Requests.
endef

$(eval $(call PyPackage,python-requests-oauthlib))
$(eval $(call BuildPackage,python-requests-oauthlib))
$(eval $(call BuildPackage,python-requests-oauthlib-src))
