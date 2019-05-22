#
# Copyright (C) 2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-paho-mqtt
PKG_VERSION:=1.4.0
PKG_RELEASE:=1

PKG_SOURCE:=paho-mqtt-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/25/63/db25e62979c2a716a74950c9ed658dce431b5cb01fde29eb6cba9489a904/
PKG_HASH:=e440a052b46d222e184be3be38676378722072fcd4dfd2c8f509fb861a7b0b79

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-paho-mqtt-$(PKG_VERSION)

PKG_LICENSE:=BSD License
PKG_LICENSE_FILES:=LICENSE.txt

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-paho-mqtt/Default
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://www.pycrypto.org/
endef

define Package/python-paho-mqtt
$(call Package/python-paho-mqtt/Default)
  TITLE:=python-paho-mqtt
  DEPENDS:=+python-light
  VARIANT:=python
endef

define Package/python3-paho-mqtt
$(call Package/python-paho-mqtt/Default)
  TITLE:=python3-paho-mqtt
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python-paho-mqtt/description
The Eclipse Paho MQTT Python client library, which implements versions 3.1 and
3.1.1 of the MQTT protocol.

This code provides a client class which enable applications to connect to
an MQTT broker to publish messages, and to subscribe to topics and receive
published messages. It also provides some helper functions to make publishing
one off messages to an MQTT server very straightforward.
endef

define Package/python3-paho-mqtt/description
$(call Package/python-paho-mqtt/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-paho-mqtt))
$(eval $(call BuildPackage,python-paho-mqtt))
$(eval $(call BuildPackage,python-paho-mqtt-src))

$(eval $(call Py3Package,python3-paho-mqtt))
$(eval $(call BuildPackage,python3-paho-mqtt))
$(eval $(call BuildPackage,python3-paho-mqtt-src))
