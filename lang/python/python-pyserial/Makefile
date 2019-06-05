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
PKG_HASH:=d657051249ce3cbd0446bcfb2be07a435e1029da4d63f53ed9b4cdde7373364c

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-pyserial-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=python

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-pyserial/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  URL:=http://pyserial.sourceforge.net
endef

define Package/python-pyserial
$(call Package/python-pyserial/Default)
  TITLE:=python-pyserial
  DEPENDS:=+PACKAGE_python-pyserial:python-light
  VARIANT:=python
endef

define Package/python3-pyserial
$(call Package/python-pyserial/Default)
  TITLE:=python3-pyserial
  DEPENDS:=+PACKAGE_python3-pyserial:python3-light
  VARIANT:=python3
endef

define Package/python-pyserial/description
	serial port python bindings
endef

define Package/python3-pyserial/description
$(call Package/python-pyserial/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-pyserial))
$(eval $(call BuildPackage,python-pyserial))
$(eval $(call BuildPackage,python-pyserial-src))

$(eval $(call Py3Package,python3-pyserial))
$(eval $(call BuildPackage,python3-pyserial))
$(eval $(call BuildPackage,python3-pyserial-src))
