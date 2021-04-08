#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python3-readline
PKG_VERSION:=6.2.4.1
PKG_RELEASE:=$(AUTORELEASE)

PYPI_NAME:=readline
PKG_HASH:=e00f86e03dfe52e7d1502cec5c64070b32621c85509c0081a4cfa6a0294bd107

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=GPL-1.0-only

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-readline
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=Python3 readline
	DEPENDS:=+python3 +libreadline
endef

define Package/python3-readline/description
  Python readline support
endef

$(eval $(call Py3Package,python3-readline))
$(eval $(call BuildPackage,python3-readline))
$(eval $(call BuildPackage,python3-readline-src))
