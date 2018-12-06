#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-oauthlib
PKG_VERSION:=2.1.0
PKG_RELEASE:=2
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=oauthlib-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/o/oauthlib
PKG_HASH:=ac35665a61c1685c56336bda97d5eefa246f1202618a1d6f34fccb1bdd404162
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-oauthlib-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-oauthlib/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
  TITLE:=A generic, spec-compliant, thorough implementation of the OAuth request-signing logic
  URL:=https://github.com/oauthlib/oauthlib
endef

define Package/python-oauthlib
  $(call Package/python-oauthlib/Default)
  DEPENDS:=+PACKAGE_python-oauthlib:python-light
  VARIANT:=python
endef

define Package/python3-oauthlib
  $(call Package/python-oauthlib/Default)
  DEPENDS:=+PACKAGE_python3-oauthlib:python3-light
  VARIANT:=python3
endef

define Package/python-oauthlib/description
  A generic, spec-compliant, thorough implementation of the OAuth request-signing logic for Python
endef

define Package/python3-oauthlib/description
$(call Package/python-oauthlib/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-oauthlib))
$(eval $(call BuildPackage,python-oauthlib))
$(eval $(call BuildPackage,python-oauthlib-src))

$(eval $(call Py3Package,python3-oauthlib))
$(eval $(call BuildPackage,python3-oauthlib))
$(eval $(call BuildPackage,python3-oauthlib-src))
