#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ipaddress
PKG_VERSION:=1.0.19
PKG_RELEASE:=2

PKG_SOURCE:=ipaddress-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/f0/ba/860a4a3e283456d6b7e2ab39ce5cf11a3490ee1a363652ac50abf9f0f5df
PKG_HASH:=200d8686011d470b5e4de207d803445deee427455cd0cb7c982b68cf82524f81

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
  URL:=https://github.com/phihag/ipaddress
endef

define Package/python-ipaddress
$(call Package/python-ipaddress/Default)
  TITLE:=python-ipaddress
  DEPENDS:=+PACKAGE_python-ipaddress:python-light
  VARIANT:=python
endef

define Package/python-ipaddress/description
Python 3.3+'s ipaddress for Python 2.6, 2.7, 3.2.
endef

$(eval $(call PyPackage,python-ipaddress))
$(eval $(call BuildPackage,python-ipaddress))
$(eval $(call BuildPackage,python-ipaddress-src))
