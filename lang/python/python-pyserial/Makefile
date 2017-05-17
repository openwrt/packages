#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyserial
PKG_VERSION:=3.1.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Micke Prag <micke.prag@telldus.se>
PKG_LICENSE:=Python-2.0

PKG_SOURCE:=pyserial-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://pypi.python.org/packages/3c/d8/a9fa247ca60b02b3bebbd61766b4f321393b57b13c53b18f6f62cf172c08/
PKG_MD5SUM:=2f72100de3e410b36d575e12e82e9d27

PKG_BUILD_DIR:=$(BUILD_DIR)/pyserial-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=python

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-pyserial
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=python-pyserial
  URL:=http://pyserial.sourceforge.net
  DEPENDS:=+python-light
endef

define Package/python-pyserial/description
	serial port python bindings
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root="$(PKG_INSTALL_DIR)")
endef

define Package/python-pyserial/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,python-pyserial))
