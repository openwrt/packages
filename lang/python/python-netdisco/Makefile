#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-netdisco
PKG_VERSION:=3.0.0
PKG_RELEASE:=1

PYPI_NAME:=netdisco
PKG_HASH:=4dbb590482f377ccc461e01742707ccbe8f1d2d1b28578af91dc9b7febcdcbd2

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.md

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-netdisco
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Discover devices on your local network
  URL:=https://github.com/home-assistant/netdisco
  DEPENDS:= \
	  +python3-light \
	  +python3-logging \
	  +python3-urllib \
	  +python3-xml \
	  +python3-requests \
	  +python3-zeroconf
endef

define Package/python3-netdisco/description
NetDisco is a Python 3 library to discover local devices and services.
It allows to scan on demand or offer a service that will scan the
network in the background in a set interval.
endef

$(eval $(call Py3Package,python3-netdisco))
$(eval $(call BuildPackage,python3-netdisco))
$(eval $(call BuildPackage,python3-netdisco-src))
