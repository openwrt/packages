# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-paho-mqtt
PKG_VERSION:=1.5.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Josef Schlehofer <josef.schlehofer@nic.cz>, Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=EPL-1.0 Eclipse Distribution License v1.0
PKG_LICENSE_FILES:=epl-v10 edl-v10

PYPI_NAME:=paho-mqtt
PKG_HASH:=e3d286198baaea195c8b3bc221941d25a3ab0e1507fc1779bdb7473806394be4

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-paho-mqtt
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=python3-paho-mqtt
  URL:=http://eclipse.org/paho
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python3-paho-mqtt/description
  MQTT version 3.1/3.1.1 client class
endef

$(eval $(call Py3Package,python3-paho-mqtt))
$(eval $(call BuildPackage,python3-paho-mqtt))
$(eval $(call BuildPackage,python3-paho-mqtt-src))
