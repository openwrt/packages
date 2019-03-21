#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-requests-oauthlib
PKG_VERSION:=1.2.0
PKG_RELEASE:=1
PKG_LICENSE:=ISC

PKG_SOURCE:=requests-oauthlib-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/r/requests-oauthlib
PKG_HASH:=bd6533330e8748e94bf0b214775fed487d309b8b8fe823dc45641ebcd9a32f57
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
