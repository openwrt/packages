#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pyptlib
PKG_VERSION:=0.0.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/p/pyptlib
PKG_MD5SUM:=2fc7b8803777451c1fad3d5e25f1b99c

PKG_BUILD_DEPENDS:=python python-setuptools

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-pyptlib
	SECTION:=lang
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-pyptlib
	URL:=https://pypi.python.org/pypi/pyptlib
	DEPENDS:=+python-light
endef

define Package/python-pyptlib/description
A python implementation of the Pluggable Transports for Circumvention
specification for Tor
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix="/usr" --root="$(PKG_INSTALL_DIR)")
endef

$(eval $(call PyPackage,python-pyptlib))
$(eval $(call BuildPackage,python-pyptlib))
