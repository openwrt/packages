#
# Copyright (C) 2023
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=python-aio-mqtt-mod
PKG_VERSION:=0.3.3
PKG_RELEASE:=1

PYPI_NAME:=aio-mqtt-mod
PKG_HASH:=2271f8a2fd6c6aea914896dc3d4dd6e384cd0da405b06dcfa566bd01f968bf9d

PKG_MAINTAINER:=Quintin Hill <stuff@quintin.me.uk>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-aio-mqtt-mod
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Asynchronous MQTT client
  URL:=https://github.com/devbis/aio-mqtt
  DEPENDS:=+python3-light +python3-asyncio +python3-openssl
endef

define Package/python3-aio-mqtt-mod/description
  Asynchronous MQTT client for 3.1.1 protocol version (mod).
endef

$(eval $(call Py3Package,python3-aio-mqtt-mod))
$(eval $(call BuildPackage,python3-aio-mqtt-mod))
$(eval $(call BuildPackage,python3-aio-mqtt-mod-src))
