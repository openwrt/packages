#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-voluptuous
PKG_VERSION:=0.11.7
PKG_RELEASE:=1

PKG_SOURCE:=voluptuous-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/v/voluptuous/
PKG_HASH:=2abc341dbc740c5e2302c7f9b8e2e243194fb4772585b991931cb5b22e9bf456

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-voluptuous-$(PKG_VERSION)

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-voluptuous/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Data validation library
  URL:=https://github.com/alecthomas/voluptuous
endef

define Package/python-voluptuous
$(call Package/python-voluptuous/Default)
  DEPENDS:= \
      +PACKAGE_python-voluptuous:python-light
  VARIANT:=python
endef

define Package/python3-voluptuous
$(call Package/python-voluptuous/Default)
  DEPENDS:= \
      +PACKAGE_python3-voluptuous:python3-light
  VARIANT:=python3
endef

define Package/python-voluptuous/description
It is primarily intended for validating data coming into Python as JSON, YAML, etc.
endef

define Package/python3-voluptuous/description
$(call Package/python-voluptuous/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-voluptuous))
$(eval $(call BuildPackage,python-voluptuous))
$(eval $(call BuildPackage,python-voluptuous-src))

$(eval $(call Py3Package,python3-voluptuous))
$(eval $(call BuildPackage,python3-voluptuous))
$(eval $(call BuildPackage,python3-voluptuous-src))
