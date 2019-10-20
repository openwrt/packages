#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ipaddress
PKG_VERSION:=1.0.23
PKG_RELEASE:=1

PKG_SOURCE:=ipaddress-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/i/ipaddress
PKG_HASH:=b7f8e0369580bb4a24d5ba1d7cc29660a4a6987763faf1d8a8046830e020e7e2

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-ipaddress-$(PKG_VERSION)

PKG_LICENSE:=Python-2.0
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-ipaddress/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python 3.3+'s ipaddress
  URL:=https://github.com/phihag/ipaddress
endef

define Package/python-ipaddress
$(call Package/python-ipaddress/Default)
  DEPENDS:=+PACKAGE_python-ipaddress:python-light
  VARIANT:=python
endef

define Package/python-ipaddress/description
Python 3.3+'s ipaddress for Python 2.6, 2.7, 3.2.
endef

$(eval $(call PyPackage,python-ipaddress))
$(eval $(call BuildPackage,python-ipaddress))
$(eval $(call BuildPackage,python-ipaddress-src))
