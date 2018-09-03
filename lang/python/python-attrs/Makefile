#
# Copyright (C) 2016-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-attrs
PKG_VERSION:=18.1.0
PKG_RELEASE:=1

PKG_SOURCE:=attrs-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/a/attrs
PKG_HASH:=e0d0eb91441a3b53dab4d9b743eafc1ac44476296a2053b6ca3af0b139faf87b

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
  URL:=http://www.attrs.org/
endef

define Package/python-attrs
$(call Package/python-attrs/Default)
  TITLE:=Classes Without Boilerplate
  DEPENDS:=+PACKAGE_python-attrs:python-light
  VARIANT:=python
endef

define Package/python3-attrs
$(call Package/python-attrs/Default)
  TITLE:=Classes Without Boilerplate
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
