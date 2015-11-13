#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ipaddress
PKG_VERSION:=1.0.15
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/i/ipaddress
PKG_MD5SUM:=12915e923b738107e47827478d553ba1

PKG_BUILD_DEPENDS:=python python-setuptools

PKG_LICENSE:=Python-2.0
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-ipaddress
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-ipaddress
	URL:=https://github.com/phihag/ipaddress
	DEPENDS:=+python-light
endef

define Package/python-ipaddress/description
Python 3.3+'s ipaddress for Python 2.6, 2.7, 3.2.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

$(eval $(call PyPackage,python-ipaddress))
$(eval $(call BuildPackage,python-ipaddress))
