#
# Copyright (C) 2011-2013 OpenWrt.org
# Copyright (C) 2010 Jo-Philipp Wich <xm@subsignal.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mosquitto
PKG_VERSION:=1.4.7
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.txt

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://mosquitto.org/files/source/
PKG_MD5SUM:=4cb978502312bff2dcdaab6a433b1bf2
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)/default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=mosquitto - an MQTT message broker
  URL:=http://www.mosquitto.org/
  MAINTAINER:=Karl Palsson <karlp@remake.is>
  DEPENDS:= +librt +libuuid
  USERID:=mosquitto=200:mosquitto=200
endef

define Package/$(PKG_NAME)
    $(call Package/mosquitto/default)
    TITLE+= (with SSL support)
    DEPENDS+= +libopenssl +MOSQUITTO_LWS:libwebsockets-openssl
    VARIANT:=ssl
endef

define Package/$(PKG_NAME)-nossl
    $(call Package/$(PKG_NAME)/default)
    TITLE+= (without SSL support)
    VARIANT:=nossl
endef

define Package/$(PKG_NAME)/config
	source "$(SOURCE)/Config.in"
endef

define Package/$(PKG_NAME)/default/description
Mosquitto is an open source (BSD licensed) message broker that implements
the MQTT protocol version 3.1 and 3.1.1. MQTT provides a lightweight
method of carrying out messaging using a publish/subscribe model.

This package also includes some basic support for configuring via UCI
endef

define Package/$(PKG_NAME)/description
	$(call Package/$(PKG_NAME)/default/description)
	This package is built with SSL support
endef

define Package/$(PKG_NAME)-nossl/description
        $(call Package/$(PKG_NAME)/default/description)
        This package is built WITHOUT SSL support.
endef


define Package/mosquitto-client/default
    $(Package/mosquitto/default)
    TITLE:= mosquitto - client tools
    DEPENDS+=+libcares
endef
define Package/mosquitto-client
    $(call Package/mosquitto-client/default)
    TITLE+= (With SSL support)
    DEPENDS+=+libmosquitto
    VARIANT:=ssl
endef
define Package/mosquitto-client-nossl
    $(call Package/mosquitto-client/default)
    TITLE+= (Without SSL support)
    DEPENDS+=+libmosquitto-nossl
    VARIANT:=nossl
endef

define Package/mosquitto-client/default/description
 Command line client tools for publishing messages to MQTT servers
and subscribing to topics.
endef

define Package/mosquitto-client/description
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
endef

define Package/libmosquitto
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
use by any third party software that wants to communicate with a
mosquitto server.

Should be useable for communicating with any MQTT v3.1/3.1.1 compatible
server, such as IBM's RSMB, in addition to Mosquitto
endef

define Package/libmosquitto/description
    $(call Package/libmosquitto/default/description)
    This package is built with SSL support
endef
define Package/libmosquitto-nossl/description
    $(call Package/libmosquitto/default/description)
    This package is built without SSL support
endef


define Package/$(PKG_NAME)/conffiles
/etc/mosquitto/mosquitto.conf
/etc/config/mosquitto
endef

Package/$(PKG_NAME)-nossl/conffiles = $(Package/$(PKG_NAME)/conffiles)

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mosquitto $(1)/usr/sbin/mosquitto
ifeq ($(CONFIG_MOSQUITTO_PASSWD),y)
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mosquitto_passwd $(1)/usr/sbin
endif
	$(INSTALL_DIR) $(1)/etc/mosquitto
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/mosquitto.conf $(1)/etc/mosquitto/mosquitto.conf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mosquitto.init $(1)/etc/init.d/mosquitto
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/mosquitto.uci.convert $(1)/usr/bin
endef
Package/$(PKG_NAME)-nossl/install = $(Package/$(PKG_NAME)/install)


define Package/mosquitto-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/client/mosquitto_pub $(1)/usr/bin/mosquitto_pub
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/client/mosquitto_sub $(1)/usr/bin/mosquitto_sub
endef
Package/mosquitto-client-nossl/install = $(Package/mosquitto-client/install)

# This installs files into ./staging_dir/. so that you can cross compile from the host
define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/lib/mosquitto.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/libmosquitto.so.1 $(1)/usr/lib/
	$(LN) libmosquitto.so.1 $(1)/usr/lib/libmosquitto.so
endef

# This installs files on the target.  Compare with Build/InstallDev
define Package/libmosquitto/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/libmosquitto.so.1 $(1)/usr/lib/
	$(LN) libmosquitto.so.1 $(1)/usr/lib/libmosquitto.so
endef
Package/libmosquitto-nossl/install = $(Package/libmosquitto/install)

# Applies to all...
MAKE_FLAGS += WITH_DOCS=no
ifeq ($(BUILD_VARIANT),nossl)
        MAKE_FLAGS += WITH_TLS=no WITH_WEBSOCKETS=no
else
	MAKE_FLAGS += WITH_WEBSOCKETS=$(if $(CONFIG_MOSQUITTO_LWS),"yes","no")
endif

$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-nossl))
$(eval $(call BuildPackage,libmosquitto))
$(eval $(call BuildPackage,libmosquitto-nossl))
$(eval $(call BuildPackage,mosquitto-client))
$(eval $(call BuildPackage,mosquitto-client-nossl))
