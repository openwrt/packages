#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-constantly
PKG_VERSION:=15.1.0
PKG_RELEASE:=1

PKG_SOURCE:=constantly-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/c/constantly
PKG_HASH:=586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-constantly-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-constantly/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Symbolic constants in Python
  URL:=https://github.com/twisted/constantly
endef

define Package/python-constantly
$(call Package/python-constantly/Default)
  DEPENDS:=+PACKAGE_python-constantly:python-light
  VARIANT:=python
endef

define Package/python3-constantly
$(call Package/python-constantly/Default)
  DEPENDS:=+PACKAGE_python3-constantly:python3-light
  VARIANT:=python3
endef

define Package/python-constantly/description
A library that provides symbolic constant support. It includes
collections and constants with text, numeric, and bit flag values.
Originally twisted.python.constants from the Twisted project.
endef

define Package/python3-constantly/description
$(call Package/python-constantly/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-constantly))
$(eval $(call BuildPackage,python-constantly))
$(eval $(call BuildPackage,python-constantly-src))

$(eval $(call Py3Package,python3-constantly))
$(eval $(call BuildPackage,python3-constantly))
$(eval $(call BuildPackage,python3-constantly-src))
