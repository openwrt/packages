#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pip
PKG_VERSION:=7.1.2
PKG_RELEASE:=3

PKG_SOURCE:=pip-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/p/pip/
PKG_MD5SUM:=3823d2343d9f3aaab21cf9c917710196

PKG_BUILD_DIR:=$(BUILD_DIR)/pip-$(PKG_VERSION)
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-pip
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Tool for installing Python packages.
  URL:=https://pip.pypa.io
  DEPENDS:=+python +python-setuptools +ca-certificates
  MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
endef

define Package/python-pip/description
  A tool for installing and managing Python packages.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,\
		install --root="$(PKG_INSTALL_DIR)" --prefix="/usr" \
		--single-version-externally-managed \
	)
endef

define PyPackage/python-pip/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/pip/_vendor/distlib/*.exe
endef

define PyPackage/python-pip/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
	$(INSTALL_CONF) ./files/pip.conf $(1)/etc/
endef

$(eval $(call PyPackage,python-pip))
$(eval $(call BuildPackage,python-pip))

