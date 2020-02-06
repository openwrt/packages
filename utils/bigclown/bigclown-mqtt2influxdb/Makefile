# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bigclown-mqtt2influxdb
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://codeload.github.com/bigclownlabs/bch-mqtt2influxdb/tar.gz/v$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=60a3ba8a3d76356ed46fbb7bcbedaf439b7edc2dfc2d43232c9250db80c77387
PKG_LICENSE:=MIT
PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>
PKG_BUILD_DIR:=$(BUILD_DIR)/bch-mqtt2influxdb-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../../lang/python/python3-package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=BigClown
  URL:=https://github.com/bigclownlabs/bch-mqtt2influxdb
  TITLE:=BigCLown MQTT to Influxdb bridge
  DEPENDS:=+python3-paho-mqtt +python3-yaml +python3-influxdb +python3-jsonpath-ng +python3-schema
endef

define Py3Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/init $(1)/etc/init.d/bigclown-mqtt2influxdb
	$(INSTALL_DATA) ./files/config.yml $(1)/etc/bigclown-mqtt2influxdb.yml
endef

define Package/$(PKG_NAME)/conffiles
/etc/bigclown-mqtt2influxdb.yml
endef

define Build/Compile
	sed -i 's/@@VERSION@@/$(PKG_VERSION)/' "$(PKG_BUILD_DIR)/setup.py"
	$(call Py3Build/Compile/Default)
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
