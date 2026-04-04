# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-paho-mqtt
PKG_VERSION:=2.1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=EPL-2.0 Eclipse Distribution License v1.0
PKG_LICENSE_FILES:=epl-v20 edl-v10 LICENSE.txt

PYPI_NAME:=paho-mqtt
PYPI_SOURCE_NAME:=paho_mqtt
PKG_HASH:=12d6e7511d4137555a3f6ea167ae846af2c7357b10bc6fa4f7c3968fc1723834

PKG_BUILD_DEPENDS:=python-hatchling/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-paho-mqtt
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=MQTT version 5.0/3.1.1 client class
  URL:=http://eclipse.org/paho
  DEPENDS:=+python3-light +python3-uuid +python3-logging +python3-urllib
endef

define Package/python3-paho-mqtt/description
  MQTT version 3.1/3.1.1/5.0 client class
endef

$(eval $(call Py3Package,python3-paho-mqtt))
$(eval $(call BuildPackage,python3-paho-mqtt))
$(eval $(call BuildPackage,python3-paho-mqtt-src))
