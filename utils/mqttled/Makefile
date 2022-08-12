
include $(TOPDIR)/rules.mk

PKG_NAME:=mqttled
PKG_VERSION:=0.1.2
PKG_RELEASE:=1

PYPI_NAME:=mqttled
PKG_HASH:=eb94af853605f4f1ea3c34b66e2f84f3d9845d795529ae8429feb954e74876d7

PKG_MAINTAINER:=Tom Grime <tom.grime@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENCE

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/mqttled
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=LED Control from MQTT 
  URL:=https://github.com/trevortrevor/mqttled/
  DEPENDS:= \
    +python3-paho-mqtt \
	+python3-uci \
	+python3-idna \
	+python3-jsonpath-ng \
	+python3-yaml \
	+python3-schema \
	+python3-netifaces \
	+python3-logging \
	+python3-urllib \
	+python3-asyncio \
	+python3-pkg-resources

endef

define Package/mqttled/description
	Exposes the LEDs of your device to an MQTT broker with optional Home Assistant auto discovery
endef

define Py3Package/mqttled/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mqttled $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mqttled.init $(1)/etc/init.d/mqttled
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/mqttled.config $(1)/etc/config/mqttled
endef

define Package/mqttled/conffiles
/etc/config/mqttled
endef

$(eval $(call Py3Package,mqttled))
$(eval $(call BuildPackage,mqttled))
