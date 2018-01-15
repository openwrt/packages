#
# Copyright (C) 2016-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-attrs
PKG_VERSION:=17.4.0
PKG_RELEASE:=2

PKG_SOURCE:=attrs-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/8b/0b/a06cfcb69d0cb004fde8bc6f0fd192d96d565d1b8aa2829f0f20adb796e5
PKG_HASH:=1c7960ccfd6a005cd9f7ba884e6316b5e430a3f1a6c37c5f87d8b43f83b54ec9

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-attrs-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-attrs/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://attrs.readthedocs.org/
endef

define Package/python-attrs
$(call Package/python-attrs/Default)
  TITLE:=python-attrs
  DEPENDS:=+PACKAGE_python-attrs:python-light
  VARIANT:=python
endef

define Package/python3-attrs
$(call Package/python-attrs/Default)
  TITLE:=python3-attrs
  DEPENDS:=+PACKAGE_python3-attrs:python3-light
  VARIANT:=python3
endef

define Package/python-attrs/description
attrs is an MIT-licensed Python package with class decorators that ease
the chores of implementing the most common attribute-related object
protocols.
endef

define Package/python3-attrs/description
$(call Package/python-attrs/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-attrs))
$(eval $(call BuildPackage,python-attrs))
$(eval $(call BuildPackage,python-attrs-src))

$(eval $(call Py3Package,python3-attrs))
$(eval $(call BuildPackage,python3-attrs))
$(eval $(call BuildPackage,python3-attrs-src))
