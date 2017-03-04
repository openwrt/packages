#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gattlib
PKG_VERSION:=0.20150805
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://pypi.python.org/packages/source/g/gattlib/
PKG_MD5SUM:=f620eca190bb7acd67c7aafecaedb6c2

PKG_BUILD_DEPENDS:=python python-setuptools

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-gattlib
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Library to access Bluetooth LE devices
  URL:=https://bitbucket.org/OscarAcena/pygattlib
  DEPENDS:=+python +boost-python +boost-thread +bluez-libs +glib2
endef

define Package/python-gattlib/description
  This is a Python library to use the GATT Protocol for Bluetooth LE devices. It
  is a wrapper around the implementation used by gatttool in bluez package. It
  does not call other binaries to do its job :)
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix="$(PKG_INSTALL_DIR)/usr")
endef

define Package/python-gattlib/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,python-gattlib))
