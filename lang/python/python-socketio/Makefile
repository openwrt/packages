#
# Copyright (C) 2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-socketio
PKG_VERSION:=5.8.0
PKG_RELEASE:=1

PYPI_NAME:=python-socketio
PKG_HASH:=e714f4dddfaaa0cb0e37a1e2deef2bb60590a5b9fea9c343dd8ca5e688416fd9

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

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
