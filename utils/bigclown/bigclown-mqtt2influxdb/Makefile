# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bigclown-mqtt2influxdb
PKG_VERSION:=1.3.0
PKG_RELEASE:=2

PYPI_NAME:=mqtt2influxdb
PKG_HASH:=1b4b3b13f5b2f092bcd27846d94e91ad6f05141b2daea5167a7d58b09a782639

PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../../lang/python/python3-package.mk

define Package/bigclown-mqtt2influxdb
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=BigClown
  TITLE:=BigCLown MQTT to Influxdb bridge
  URL:=https://github.com/bigclownlabs/bch-mqtt2influxdb
  DEPENDS:= \
    +python3-paho-mqtt \
    +python3-yaml \
    +python3-influxdb \
    +python3-jsonpath-ng \
    +python3-schema
endef

define Py3Package/bigclown-mqtt2influxdb/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/init $(1)/etc/init.d/bigclown-mqtt2influxdb
	$(INSTALL_DATA) ./files/config.yml $(1)/etc/bigclown-mqtt2influxdb.yml
endef

define Package/bigclown-mqtt2influxdb/conffiles
/etc/bigclown-mqtt2influxdb.yml
endef

$(eval $(call Py3Package,bigclown-mqtt2influxdb))
$(eval $(call BuildPackage,bigclown-mqtt2influxdb))
