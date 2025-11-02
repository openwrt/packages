#
# Copyright (C) 2021 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-flask-socketio
PKG_VERSION:=5.5.1
PKG_RELEASE:=1

PYPI_NAME:=Flask-SocketIO
PYPI_SOURCE_NAME:=flask_socketio
PKG_HASH:=d946c944a1074ccad8e99485a6f5c79bc5789e3ea4df0bb9c864939586c51ec4

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-flask-socketio
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Socket.IO integration for Flask
  URL:=https://github.com/miguelgrinberg/Flask-SocketIO/
  DEPENDS:= \
	+python3-light \
	+python3-flask \
	+python3-socketio
endef

define Package/python3-flask-socketio/description
  Flask-SocketIO gives Flask applications access to low latency
  bi-directional communications between the clients and the server.
endef

$(eval $(call Py3Package,python3-flask-socketio))
$(eval $(call BuildPackage,python3-flask-socketio))
$(eval $(call BuildPackage,python3-flask-socketio-src))
