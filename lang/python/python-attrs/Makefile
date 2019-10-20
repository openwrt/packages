#
# Copyright (C) 2016-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-attrs
PKG_VERSION:=19.3.0
PKG_RELEASE:=1

PKG_SOURCE:=attrs-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/a/attrs
PKG_HASH:=f7b7ce16570fe9965acd6d30101a28f62fb4a7f9e926b3bbc9b61f8b04247e72

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
  TITLE:=Classes Without Boilerplate
  URL:=https://www.attrs.org/
endef

define Package/python-attrs
$(call Package/python-attrs/Default)
  DEPENDS:=+PACKAGE_python-attrs:python-light
  VARIANT:=python
endef

define Package/python3-attrs
$(call Package/python-attrs/Default)
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
