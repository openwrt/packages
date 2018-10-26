#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-requests
PKG_VERSION:=2.20.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0

PKG_SOURCE:=requests-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/r/requests
PKG_HASH:=99dcfdaaeb17caf6e526f32b6a7b780461512ab3f1d992187801694cba42770c
PKG_BUILD_DIR:=$(BUILD_DIR)/requests-$(PKG_VERSION)

PKG_CPE_ID:=cpe:/a:python-requests:requests

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
