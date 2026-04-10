#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pip
PKG_VERSION:=26.0.1
PKG_RELEASE:=1

PYPI_NAME:=pip
PKG_HASH:=c4037d8a277c89b320abe636d59f91e6d0922d08a05b60e85e53b296613346d8

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_CPE_ID:=cpe:/a:pypa:pip

PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pip
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=PyPA recommended tool for installing Python packages
  URL:=https://pip.pypa.io/
  DEPENDS:=+python3
endef

define Package/python3-pip/description
pip is the package installer for Python. You can use pip to install
packages from the Python Package Index and other indexes.
endef

define Package/python3-pip/conffiles
/etc/pip.conf
endef

define Py3Package/python3-pip/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pip3 $(1)/usr/bin/
	$(LN) pip3 $(1)/usr/bin/pip

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/pip.conf $(1)/etc/
endef

$(eval $(call Py3Package,python3-pip))
$(eval $(call BuildPackage,python3-pip))
$(eval $(call BuildPackage,python3-pip-src))
