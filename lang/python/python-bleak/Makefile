#
# Copyright (C) 2023
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=python-bleak
PKG_VERSION:=0.20.1
PKG_RELEASE:=1

PYPI_NAME:=bleak
PKG_HASH:=db599f5f100e252e9cdd4020c8657daca0371a3c697e87432abc702f3774cb4c

PKG_MAINTAINER:=Quintin Hill <stuff@quintin.me.uk>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-bleak
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Bluetooth Low Energy platform Agnostic Klient
  URL:=https://github.com/hbldh/bleak
  DEPENDS:=+python3-light +python3-async-timeout +python3-asyncio \
	+python3-dbus-fast +python3-ctypes +python3-logging
endef

define Package/python3-bleak/description
  Bleak is an acronym for Bluetooth Low Energy platform Agnostic Klient.
  Bleak is a GATT client software, capable of connecting to BLE devices acting
  as GATT servers.  It is designed to provide a asynchronous, cross-platform
  Python API to connect and communicate with e.g. sensors.
endef

$(eval $(call Py3Package,python3-bleak))
$(eval $(call BuildPackage,python3-bleak))
$(eval $(call BuildPackage,python3-bleak-src))
