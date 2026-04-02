include $(TOPDIR)/rules.mk

PKG_NAME:=vzlogger
PKG_VERSION:=0.8.9
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/volkszaehler/vzlogger/archive/refs/tags/
PKG_HASH:=734fcd78ef5e1a41913fdef627b8382d9c0c04cb99fe023cdb50dc2ad2d972a4

PKG_MAINTAINER:=Andy Voigt <a.voigt@mailbox.org>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_INSTALL:=1
CMAKE_OPTIONS += -DBUILD_TEST:BOOL=OFF

define Package/vzlogger
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=vzlogger
  URL:=volkszaehler.org
  DEPENDS:=+libmosquitto-ssl +libsml +libmicrohttpd-no-ssl +libcurl +libunistring +libsasl2 +libgcrypt +libgnutls +libstdcpp +libjson-c
endef

define Package/vzlogger/description
  vzlogger is a tool to read values from sensors and smartmeters. 
  It is used to collect data which can be forwarded to the volkszaehler.org Middleware 
  or to an MQTT broker
endef

define Package/vzlogger/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d $(1)/etc/config
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/vzlogger $(1)/usr/bin/
	$(INSTALL_BIN) ./files/vzlogger.init $(1)/etc/init.d/vzlogger
	$(INSTALL_CONF) ./files/vzlogger.conf $(1)/etc/config/vzlogger.conf
endef

$(eval $(call BuildPackage,vzlogger))
