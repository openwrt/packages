include $(TOPDIR)/rules.mk

PKG_NAME:=libpahomqtt
PKG_VERSION:=1.3.9
PKG_RELEASE=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/eclipse/paho.mqtt.c/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=386c9b5fa1cf6d0d516db12d57fd8f6a410dd0fdc5e9a2da870aae437a2535ed
PKG_BUILD_DIR:=$(BUILD_DIR)/paho.mqtt.c-$(PKG_VERSION)

PKG_MAINTAINER:=Nian Bohung <n0404.n0404@gmail.com>
PKG_LICENSE:=Eclipse Public License 2.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libpahomqtt
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=Eclipse Paho MQTT C library
	DEPENDS:=+libopenssl +libpthread
	URL:=https://github.com/eclipse/paho.mqtt.c
endef

CMAKE_OPTIONS += \
		-DPAHO_WITH_SSL=TRUE \
		-DPAHO_HIGH_PERFORMANCE=TRUE

define Package/libpahomqtt/description
	This library provides functions for mqtt client.
endef

define Package/libpahomqtt/install
	$(INSTALL_DIR) $(1)/usr
	$(CP) $(PKG_INSTALL_DIR)/usr/* $(1)/usr
endef

$(eval $(call BuildPackage,libpahomqtt))
