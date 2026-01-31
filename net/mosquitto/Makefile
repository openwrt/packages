#
# Copyright (C) 2011-2013 OpenWrt.org
# Copyright (C) 2010 Jo-Philipp Wich <xm@subsignal.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mosquitto
PKG_VERSION:=2.0.22
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://mosquitto.org/files/source/
PKG_HASH:=2f752589ef7db40260b633fbdb536e9a04b446a315138d64a7ff3c14e2de6b68

PKG_LICENSE:=EPL-2.0
PKG_LICENSE_FILES:=LICENSE.txt
PKG_CPE_ID:=cpe:/a:eclipse:mosquitto

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/mosquitto/default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=mosquitto - an MQTT message broker
  URL:=https://mosquitto.org/
  MAINTAINER:=Karl Palsson <karlp@etactica.com>
  DEPENDS:= +librt
  USERID:=mosquitto=200:mosquitto=200
endef

define Package/mosquitto-ssl
    $(call Package/mosquitto/default)
    TITLE+= (with SSL support)
    DEPENDS+= +libopenssl +MOSQUITTO_LWS:libwebsockets-openssl +MOSQUITTO_DYNAMIC_SECURITY:cJSON
    VARIANT:=ssl
    PROVIDES:=mosquitto
endef

define Package/mosquitto-nossl
    $(call Package/mosquitto/default)
    TITLE+= (without SSL support)
    VARIANT:=nossl
    PROVIDES:=mosquitto
endef

define Package/mosquitto-ssl/config
	source "$(SOURCE)/Config.in"
endef

define Package/mosquitto/default/description
Mosquitto is an open source (BSD licensed) message broker that implements
the MQTT protocol version 3.1, 3.1.1 and 5. MQTT provides a lightweight
method of carrying out messaging using a publish/subscribe model.

This package also includes some basic support for configuring via UCI
endef

define Package/mosquitto-ssl/description
	$(call Package/mosquitto/default/description)
This package is built with SSL support.  TLS-PSK will be included (in both
the client and broker) if OpenSSL is built with TLS-PSK support.
endef

define Package/mosquitto-nossl/description
        $(call Package/mosquitto/default/description)
        This package is built WITHOUT SSL support.
endef


define Package/mosquitto-client/default
    $(Package/mosquitto/default)
    TITLE:= mosquitto - client tools
    DEPENDS+=+libcares +cJSON
    PROVIDES:=mosquitto-client
endef
define Package/mosquitto-client-ssl
    $(call Package/mosquitto-client/default)
    TITLE+= (With SSL support)
    DEPENDS+=+libmosquitto-ssl
    VARIANT:=ssl
endef
define Package/mosquitto-client-nossl
    $(call Package/mosquitto-client/default)
    TITLE+= (Without SSL support)
    DEPENDS+=+libmosquitto-nossl
    VARIANT:=nossl
endef

define Package/mosquitto-client/default/description
 Command line client tools for working with mosquitto.
This includes mosquitto_sub, mosquitto_pub, mosquitto_rr
and the mosquitto_ctrl tool.
endef

define Package/mosquitto-client-ssl/description
$(call Package/mosquitto-client/default/description)
        This package is built with SSL support
endef
define Package/mosquitto-client-nossl/description
$(call Package/mosquitto-client/default/description)
        This package is built without SSL support
endef

define Package/libmosquitto/default
    $(Package/mosquitto/default)
    SECTION:=libs
    CATEGORY:=Libraries
    DEPENDS:=+libpthread +librt +libcares
    TITLE:= mosquitto - client library
    PROVIDES:=libmosquitto
endef

define Package/libmosquitto-ssl
    $(call Package/libmosquitto/default)
    TITLE+= (With SSL Support)
    DEPENDS+= +libopenssl
    VARIANT=ssl
endef
define Package/libmosquitto-nossl
    $(call Package/libmosquitto/default)
    TITLE+= (Without SSL Support)
    VARIANT=nossl
endef

define Package/libmosquitto/default/description
 Library required for mosquitto's command line client tools, also for
use by any third party software that wants to communicate with _any_
MQTT server.

Should be usable for communicating with any MQTT v3.1/3.1.1/5 compatible
server, in addition to Mosquitto.
endef

define Package/libmosquitto-ssl/description
    $(call Package/libmosquitto/default/description)
    This package is built with SSL support
endef
define Package/libmosquitto-nossl/description
    $(call Package/libmosquitto/default/description)
    This package is built without SSL support
endef

define Package/libmosquittopp
    SECTION:=libs
    CATEGORY:=Libraries
    DEPENDS:=libmosquitto +libstdcpp
    TITLE:= mosquitto - client c++ library
endef

define Package/libmosquittopp/description
 C++ Library wrapper for libmosquitto.
endef

define Package/mosquitto-ssl/conffiles
/etc/mosquitto/mosquitto.conf
/etc/config/mosquitto
endef

Package/mosquitto-nossl/conffiles = $(Package/mosquitto-ssl/conffiles)

define Package/mosquitto/install/default
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/mosquitto $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/mosquitto
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/etc/mosquitto/mosquitto.conf $(1)/etc/mosquitto
	$(CP) ./files/* $(1)/
endef

define Package/mosquitto-nossl/install
	$(call Package/mosquitto/install/default,$(1))
endef

define Package/mosquitto-ssl/install
	$(call Package/mosquitto/install/default,$(1))
ifeq ($(CONFIG_MOSQUITTO_PASSWD),y)
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mosquitto_passwd $(1)/usr/bin
endif
ifeq ($(CONFIG_MOSQUITTO_DYNAMIC_SECURITY),y)
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/mosquitto_dynamic_security.so $(1)/usr/lib
endif
endef

define Package/mosquitto-client-nossl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mosquitto_pub $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mosquitto_sub $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mosquitto_rr $(1)/usr/bin
endef
define Package/mosquitto-client-ssl/install
	$(call Package/mosquitto-client-nossl/install,$(1))
ifeq ($(CONFIG_MOSQUITTO_CTRL),y)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mosquitto_ctrl $(1)/usr/bin
endif
endef

# This installs files into ./staging_dir/. so that you can cross compile from the host
define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmosquitto.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmosquittopp.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
endef

# This installs files on the target.  Compare with Build/InstallDev
define Package/libmosquitto-ssl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libmosquitto.so.* $(1)/usr/lib/
endef
Package/libmosquitto-nossl/install = $(Package/libmosquitto-ssl/install)

define Package/libmosquittopp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libmosquittopp.so.* $(1)/usr/lib/
endef

# Applies to all...
CMAKE_OPTIONS += \
	-DDOCUMENTATION=OFF \
	-DWITH_ADNS=OFF \
	-DWITH_BUNDLED_DEPS=ON \
	-DWITH_DLT=OFF \
	-DWITH_PERSISTENCE=ON \
	-DWITH_PIC=ON \
	-DWITH_SOCKS=ON \
	-DWITH_SRV=ON \
	-DWITH_SYSTEMD=OFF \
	-DWITH_SYS_TREE=ON \
	-DWITH_THREADING=ON

ifeq ($(BUILD_VARIANT),nossl)
	CMAKE_OPTIONS += -DWITH_TLS=OFF -DWITH_WEBSOCKETS=OFF
else
	CMAKE_OPTIONS += -DWITH_TLS_PSK=O$(if $(CONFIG_OPENSSL_WITH_PSK),N,FF)
	CMAKE_OPTIONS += -DWITH_WEBSOCKETS=O$(if $(CONFIG_MOSQUITTO_LWS),N,FF)
endif

$(eval $(call BuildPackage,mosquitto-ssl))
$(eval $(call BuildPackage,mosquitto-nossl))
$(eval $(call BuildPackage,libmosquitto-ssl))
$(eval $(call BuildPackage,libmosquitto-nossl))
$(eval $(call BuildPackage,libmosquittopp))
$(eval $(call BuildPackage,mosquitto-client-ssl))
$(eval $(call BuildPackage,mosquitto-client-nossl))
