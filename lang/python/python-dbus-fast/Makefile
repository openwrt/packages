#
# Copyright (C) 2023
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=python-dbus-fast
PKG_VERSION:=2.44.1
PKG_RELEASE:=1

PYPI_NAME:=dbus-fast
PYPI_SOURCE_NAME:=dbus_fast
PKG_HASH:=b027e96c39ed5622bb54d811dcdbbe9d9d6edec3454808a85a1ceb1867d9e25c

PKG_MAINTAINER:=Quintin Hill <stuff@quintin.me.uk>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-poetry-core/host python-cython/host python-wheel/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-dbus-fast
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=A faster version of dbus-next
  URL:=https://github.com/Bluetooth-Devices/dbus-fast
  DEPENDS:=+python3-light +python3-async-timeout +python3-asyncio \
	+python3-logging +python3-urllib +python3-xml
endef

define Package/python3-dbus-fast/description
  dbus-fast is a Python library for DBus that aims to be a performant fully
  featured high level library primarily geared towards integration of
  applications into Linux desktop and mobile environments.
endef

$(eval $(call Py3Package,python3-dbus-fast))
$(eval $(call BuildPackage,python3-dbus-fast))
$(eval $(call BuildPackage,python3-dbus-fast-src))
