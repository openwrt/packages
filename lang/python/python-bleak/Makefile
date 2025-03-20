#
# Copyright (C) 2023
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=python-bleak
PKG_VERSION:=0.22.3
PKG_RELEASE:=1

PYPI_NAME:=bleak
PKG_HASH:=3149c3c19657e457727aa53d9d6aeb89658495822cd240afd8aeca4dd09c045c

PKG_MAINTAINER:=Quintin Hill <stuff@quintin.me.uk>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-poetry-core/host

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
	+python3-dbus-fast +python3-ctypes +python3-typing-extensions +python3-logging
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
