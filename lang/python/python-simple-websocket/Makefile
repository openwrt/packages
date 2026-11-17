# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-simple-websocket
PKG_VERSION:=1.1.0
PKG_RELEASE:=1

PYPI_NAME:=simple-websocket
PYPI_SOURCE_NAME:=simple_websocket
PKG_HASH:=7939234e7aa067c534abdab3a9ed933ec9ce4691b0713c78acb195560aa52ae4

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-simple-websocket
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Simple WebSocket and WAMP client and server
  URL:=https://github.com/miguelgrinberg/simple-websocket
  DEPENDS:= \
	+python3-light \
	+python3-wsproto
endef

define Package/python3-simple-websocket/description
  Simple WebSocket and WAMP client and server for Python.
endef

$(eval $(call Py3Package,python3-simple-websocket))
$(eval $(call BuildPackage,python3-simple-websocket))
$(eval $(call BuildPackage,python3-simple-websocket-src))
