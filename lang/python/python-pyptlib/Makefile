#
# Copyright (C) 2015, 2017-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pyptlib
PKG_VERSION:=0.0.6
PKG_RELEASE:=3

PYPI_NAME:=pyptlib
PKG_HASH:=b98472e3d9e8f4689d3913ca8f89afa5e6cc5383dcd8686987606166f9dac607

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-pyptlib/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Pluggable Transports for Tor
  URL:=https://pypi.org/project/pyptlib/
endef

define Package/python-pyptlib
$(call Package/python-pyptlib/Default)
  DEPENDS:=+PACKAGE_python-pyptlib:python-light
  VARIANT:=python
endef

define Package/python-pyptlib/description
A python implementation of the Pluggable Transports for Circumvention
specification for Tor
endef

$(eval $(call PyPackage,python-pyptlib))
$(eval $(call BuildPackage,python-pyptlib))
$(eval $(call BuildPackage,python-pyptlib-src))
