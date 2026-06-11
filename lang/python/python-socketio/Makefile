#
# Copyright (C) 2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-socketio
PKG_VERSION:=5.16.2
PKG_RELEASE:=1

PYPI_NAME:=python-socketio
PYPI_SOURCE_NAME:=python_socketio
PKG_HASH:=ad88c228d921646efa436c0a0df217e364ef30ec072df4041484e54d49c15989

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-socketio
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Socket.IO server and client
  URL:=https://github.com/miguelgrinberg/python-socketio
  DEPENDS:= \
	+python3-light \
	+python3-bidict \
	+python3-engineio \
	+python3-asyncio \
	+python3-logging \
	+python3-uuid
endef

define Package/python3-socketio/description
  Python implementation of the Socket.IO realtime client and server.
endef

$(eval $(call Py3Package,python3-socketio))
$(eval $(call BuildPackage,python3-socketio))
$(eval $(call BuildPackage,python3-socketio-src))
