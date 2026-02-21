include $(TOPDIR)/rules.mk

PKG_NAME:=vzlogger
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/volkszaehler/vzlogger.git
PKG_RELEASE:=1
PKG_SOURCE_DATE:=2025-10-06
PKG_SOURCE_VERSION:=fdad271ea3884f1ee970a8b0b6c42451d93f20a4

PKG_MAINTAINER:=Andy Voigt <a.voigt@mailbox.org>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_INSTALL:=1
CMAKE_OPTIONS += \
	-DBUILD_TEST:BOOL=OFF

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
