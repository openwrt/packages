#
# Copyright (C) 2010-2016 OpenWrt.org
# Copyright (C) 2009-2016 Thomas Heil <heil@terminal-consulting.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=haproxy
PKG_VERSION:=1.8.4
PKG_RELEASE:=01

PKG_SOURCE:=haproxy-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.haproxy.org/download/1.8/src/
PKG_HASH:=e305b0a4e7dec08072841eef6ac6dcd1b5586b1eff09c2d51e152a912e8884a6

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0
MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>

include $(INCLUDE_DIR)/package.mk

define Package/haproxy/Default
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  TITLE:=The Reliable, High Performance TCP/HTTP Load Balancer
  URL:=https://www.haproxy.org/
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

define Package/haproxy/Default/conffiles
/etc/haproxy.cfg
endef

define Package/haproxy/Default/description
 Open source Reliable, High Performance TCP/HTTP Load Balancer.
endef

define Package/haproxy
  DEPENDS+= +libpcre +libltdl +zlib +libpthread +libopenssl +libncursesw +libreadline +libatomic +@OPENSSL_WITH_DEPRECATED +@OPENSSL_WITH_EC +@OPENSSL_WITH_EC2M  +@OPENSSL_WITH_DTLS +@OPENSSL_WITH_COMPRESSION +@OPENSSL_WITH_NPN  +@OPENSSL_WITH_PSK +@OPENSSL_WITH_SRP +@OPENSSL_ENGINE_DIGEST +@OPENSSL_ENGINE_CRYPTO

  TITLE+= (with SSL support)
  VARIANT:=ssl
$(call Package/haproxy/Default)
endef

define Package/haproxy/conffiles
$(call Package/haproxy/Default/conffiles)
endef

define Package/haproxy/description
$(call Package/haproxy/Default/description)
 This package is built with SSL and LUA support.
endef

define Package/haproxy/config
	select CONFIG_OPENSSL_WITH_DEPRECATED
	$(call Package/haproxy/Default/config)
endef

define Package/haproxy-nossl
  TITLE+= (without SSL support)
  VARIANT:=nossl
  DEPENDS+= +libpcre +libltdl +zlib +libpthread +libatomic
  TITLE+= (without SSL support)
$(call Package/haproxy/Default)
endef

define Package/haproxy-nossl/conffiles
$(call Package/haproxy/Default/conffiles)
endef

define Package/haproxy-nossl/description
$(call Package/haproxy/Default/description)
 This package is built without SSL support.
endef

ENABLE_LUA:=y
ENABLE_REGPARM:=n

ifeq ($(CONFIG_mips),y)
  ENABLE_LUA:=n
endif
ifeq ($(CONFIG_mipsel),y)
  ENABLE_LUA:=n
endif

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
		LD="$(TARGET_CC)" \
		LDFLAGS="$(TARGET_LDFLAGS) -latomic" \
		IGNOREGIT=1

	$(MAKE_VARS) $(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		LD="$(TARGET_CC)" \
                LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE_FLAGS) \
		install

	$(MAKE_VARS) $(MAKE) -C $(PKG_BUILD_DIR)/contrib/halog \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		$(MAKE_FLAGS) \
		ADDLIB="-lcrypto" \
		VERSION="$(PKG_VERSION)-patch$(PKG_RELEASE)" \
		halog
endef

define Package/haproxy/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/haproxy $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/haproxy.cfg $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/haproxy.init $(1)/etc/init.d/haproxy
	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_BIN) ./files/haproxy.hotplug $(1)/etc/hotplug.d/net/90-haproxy
endef

Package/haproxy-nossl/install = $(Package/haproxy/install)

define Package/halog
	MENU:=1
	$(call Package/haproxy)
	TITLE+= halog
	DEPENDS:=haproxy
endef

define Package/halog/description
	HAProxy Log Analyzer
endef

define Package/halog/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/contrib/halog/halog $(1)/usr/bin/
endef

$(eval $(call Download,lua534))
$(eval $(call BuildPackage,haproxy))
$(eval $(call BuildPackage,halog))
$(eval $(call BuildPackage,haproxy-nossl))
