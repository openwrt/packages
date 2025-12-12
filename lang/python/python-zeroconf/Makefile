#
# Copyright (C) 2019-2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-zeroconf
PKG_VERSION:=0.131.0
PKG_RELEASE:=1

PYPI_NAME:=zeroconf
PKG_HASH:=90c431e99192a044a5e0217afd7ca0ca9824af93190332e6f7baf4da5375f331

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=python-cython/host python-poetry-core/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-zeroconf
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Multicast DNS Service Discovery Library
  URL:=https://github.com/python-zeroconf/python-zeroconf
  DEPENDS:= \
	  +python3-light \
	  +python3-asyncio \
	  +python3-logging \
	  +python3-ifaddr
endef

define Package/python3-zeroconf/description
  Pure Python Multicast DNS Service Discovery Library (Bonjour/Avahi compatible)
endef

$(eval $(call Py3Package,python3-zeroconf))
$(eval $(call BuildPackage,python3-zeroconf))
$(eval $(call BuildPackage,python3-zeroconf-src))
