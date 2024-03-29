# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-paho-mqtt
PKG_VERSION:=1.6.1
PKG_RELEASE:=2

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=EPL-2.0 Eclipse Distribution License v1.0
PKG_LICENSE_FILES:=epl-v20 edl-v10 LICENSE.txt

PYPI_NAME:=paho-mqtt
PKG_HASH:=2a8291c81623aec00372b5a85558a372c747cbca8e9934dfe218638b8eefc26f

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-paho-mqtt
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=MQTT version 5.0/3.1.1 client class
  URL:=http://eclipse.org/paho
  DEPENDS:=+python3-light +python3-uuid
endef

define Package/python3-paho-mqtt/description
  MQTT version 3.1/3.1.1/5.0 client class
endef

$(eval $(call Py3Package,python3-paho-mqtt))
$(eval $(call BuildPackage,python3-paho-mqtt))
$(eval $(call BuildPackage,python3-paho-mqtt-src))
