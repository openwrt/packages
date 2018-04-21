#
# Copyright (C) 2010-2016 OpenWrt.org
# Copyright (C) 2009-2016 Thomas Heil <heil@terminal-consulting.de>
# Copyright (C) 2018 Christian Lachner <gladiac@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nuster
PKG_VERSION:=1.7.9.9
PKG_RELEASE:=01

PKG_SOURCE:=nuster-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/jiangwenyuan/nuster/releases/download/v$(PKG_VERSION)/
PKG_HASH:=1ff2e701acd436a457ec3a7ff41d56a58c3fb7c6e09f4f0d9f9cbcedc2adab4b

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0
MAINTAINER:=Christian Lachner <gladiac@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/nuster/Default
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A caching proxy server based on HAProxy
  URL:=https://github.com/jiangwenyuan/nuster/
endef

define Download/lua534
	FILE:=lua-5.3.4.tar.gz
	URL:=https://www.lua.org/ftp/
	HASH:=f681aa518233bc407e23acf0f5887c884f17436f000d453b2491a9f11a52400c
endef

define Build/Prepare
	$(call Build/Prepare/Default)
ifeq ($(ENABLE_LUA),y)
	tar -zxvf $(DL_DIR)/lua-5.3.4.tar.gz -C $(PKG_BUILD_DIR)
	ln -s $(PKG_BUILD_DIR)/lua-5.3.4 $(PKG_BUILD_DIR)/lua
endif
endef

define Package/nuster/Default/conffiles
/etc/nuster.cfg
endef

define Package/nuster/Default/description
 A caching proxy server based on HAProxy.
endef

define Package/nuster
  DEPENDS+= +libpcre +libltdl +zlib +libpthread +libopenssl +libncursesw +libreadline +@OPENSSL_WITH_DEPRECATED +@OPENSSL_WITH_EC +@OPENSSL_WITH_EC2M  +@OPENSSL_WITH_DTLS +@OPENSSL_WITH_COMPRESSION +@OPENSSL_WITH_NPN  +@OPENSSL_WITH_PSK +@OPENSSL_WITH_SRP +@OPENSSL_ENGINE_DIGEST +@OPENSSL_ENGINE_CRYPTO

  TITLE+= (with SSL support)
  VARIANT:=ssl
$(call Package/nuster/Default)
endef

define Package/nuster/conffiles
$(call Package/nuster/Default/conffiles)
endef

define Package/nuster/description
$(call Package/nuster/Default/description)
 This package is built with SSL and LUA support.
endef

define Package/nuster/config
	select CONFIG_OPENSSL_WITH_DEPRECATED
	$(call Package/nuster/Default/config)
endef

define Package/nuster-nossl
  TITLE+= (without SSL support)
  VARIANT:=nossl
  DEPENDS+= +libpcre +libltdl +zlib +libpthread
  TITLE+= (without SSL support)
$(call Package/nuster/Default)
endef

define Package/nuster-nossl/conffiles
$(call Package/nuster/Default/conffiles)
endef

define Package/nuster-nossl/description
$(call Package/nuster/Default/description)
 This package is built without SSL support.
endef

ENABLE_LUA:=y
ENABLE_REGPARM:=n

ifeq ($(CONFIG_TARGET_x86),y)
  ENABLE_REGPARM:=y
endif

ifeq ($(CONFIG_avr32),y)
  LINUX_TARGET:=linux26
else
  LINUX_TARGET:=linux2628
endif

ifeq ($(BUILD_VARIANT),ssl)
	ADDON+=USE_OPENSSL=1
	ADDON+=ADDLIB="-lcrypto -lm "
endif

ifeq ($(ENABLE_LUA),y)
	ADDON+=USE_LUA=1
	ADDON+=LUA_LIB_NAME="lua534"
	ADDON+=LUA_INC="$(STAGING_DIR)/lua-5.3.4/include"
	ADDON+=LUA_LIB="$(STAGING_DIR)/lua-5.3.4/lib"
endif

ifeq ($(ENABLE_REGPARM),y)
	ADDON+=USE_REGPARM=1
endif

ifeq ($(ENABLE_LUA),y)
define Build/Compile/lua
	$(MAKE) TARGET=$(LINUX_TARGET) -C $(PKG_BUILD_DIR)/lua \
		INSTALL_TOP="$(STAGING_DIR)/lua-5.3.4/" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) -lncurses -lreadline" \
		LD="$(TARGET_LD)" \
		linux install

	mv $(STAGING_DIR)/lua-5.3.4/lib/liblua.a $(STAGING_DIR)/lua-5.3.4/lib/liblua534.a
endef
endif

define Build/Compile
	$(call Build/Compile/lua)
	$(MAKE) TARGET=$(LINUX_TARGET) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		CC="$(TARGET_CC)" \
		PCREDIR="$(STAGING_DIR)/usr/" \
		SMALL_OPTS="-DBUFSIZE=16384 -DMAXREWRITE=1030 -DSYSTEM_MAXCONN=165530 " \
		USE_LINUX_TPROXY=1 USE_LINUX_SPLICE=1 USE_TFO=1 \
		USE_ZLIB=yes USE_PCRE=1 USE_PCRE_JIT=1 USE_GETADDRINFO=1 \
		VERSION="$(PKG_VERSION)-patch$(PKG_RELEASE)" \
		$(ADDON) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LD="$(TARGET_CC)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		IGNOREGIT=1

	$(MAKE_VARS) $(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		LD="$(TARGET_CC)" \
                LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE_FLAGS) \
		install
endef

define Package/nuster/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/haproxy $(1)/usr/sbin/nuster
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/nuster.cfg $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nuster.init $(1)/etc/init.d/nuster
	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_BIN) ./files/nuster.hotplug $(1)/etc/hotplug.d/net/90-nuster
endef

Package/nuster-nossl/install = $(Package/nuster/install)

$(eval $(call Download,lua534))
$(eval $(call BuildPackage,nuster))
$(eval $(call BuildPackage,nuster-nossl))
