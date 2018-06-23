#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-requests
PKG_VERSION:=2.19.1
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0

PKG_SOURCE:=requests-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/54/1f/782a5734931ddf2e1494e4cd615a51ff98e1879cbe9eecbdfeaf09aa75e9
PKG_HASH:=ec22d826a36ed72a7358ff3fe56cbd4ba69dd7a6718ffd450ff0e9df7a47ce6a
PKG_BUILD_DIR:=$(BUILD_DIR)/requests-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-requests
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
  TITLE:=HTTP library for Python
  URL:=http://python-requests.org/
  DEPENDS:=+python +chardet +python-idna +python-urllib3 +python-certifi
endef

define Package/python-requests/description
  Requests is the only Non-GMO HTTP library for Python, safe for human consumption.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/python-requests/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,python-requests))
