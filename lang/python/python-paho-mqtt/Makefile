#
# Copyright (C) 2018-2019 Global Satellite Engineering
#                         (Daniel Santos <daniel.santos@pobox.com>)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-paho-mqtt
PKG_VERSION:=1.3.1
PKG_RELEASE:=1
PKG_MAINTAINER:=Daniel Santos <daniel.santos@pobox.com>
PKG_LICENSE:=EPL-1.0 BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.txt epl-v10 edl-v10

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/eclipse/paho.mqtt.python/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=7cefe65d82acb49be1282294acb12caf7ec86ede9de5b85ea3cc12e8aa6ca7ca

PKG_SOURCE_SUBDIR:=$(BUILD_VARIANT)-paho-mqtt-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-paho-mqtt-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-paho-mqtt/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  VARIANT:=$(1)
  TITLE:=Eclipse Paho MQTT Client Library ($(1))
  URL:=https://www.eclipse.org/paho/clients/python
  DEPENDS:= \
	+PACKAGE_$(1)-paho-mqtt:$(1)-light \
	+PACKAGE_$(1)-paho-mqtt:$(1)-idna \
	+PACKAGE_$(1)-paho-mqtt:$(1)-logging
endef

define Package/python-paho-mqtt
$(call Package/python-paho-mqtt/Default,python)
endef

define Package/python3-paho-mqtt
$(call Package/python-paho-mqtt/Default,python3)
endef

define Package/python-paho-mqtt/description
  MQTT version 3.1.1 client implementation
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
