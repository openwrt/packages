#
# Copyright (C) 2010-2013 OpenWrt.org
# Copyright (C) 2009-2014 Thomas Heil <heil@terminal-consulting.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=haproxy
PKG_VERSION:=1.5.4
PKG_RELEASE:=13
PKG_SOURCE:=haproxy-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://haproxy.1wt.eu/download/1.5/src/
PKG_MD5SUM:=b027035bfd8f28326634f802c3447a34
PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>
PKG_LICENSE:=GPL-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/haproxy/Default
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  TITLE:=The TCP/HTTP Load Balancer
  URL:=http://haproxy.1wt.eu/
  DEPENDS:=+libpcre +libltdl +zlib +libpthread
endef

define Package/haproxy/Default/conffiles
/etc/haproxy.cfg
endef

define Package/haproxy/Default/description
 Open source Reliable, High Performance TCP/HTTP Load Balancer.
endef

define Package/haproxy
$(call Package/haproxy/Default)
  DEPENDS+= +libopenssl
  TITLE+= (with SSL support)
  VARIANT:=ssl
endef

define Package/haproxy/conffiles
$(call Package/haproxy/Default/conffiles)
endef

define Package/haproxy/description
$(call Package/haproxy/Default/description)
 This package is built with SSL support.
endef

define Package/haproxy-nossl
$(call Package/haproxy/Default)
  TITLE+= (without SSL support)
  VARIANT:=nossl
endef

define Package/haproxy-nossl/conffiles
$(call Package/haproxy/Default/conffiles)
endef

define Package/haproxy-nossl/description
$(call Package/haproxy/Default/description)
 This package is built without SSL support.
endef

ifeq ($(CONFIG_avr32),y)
  LINUX_TARGET:=linux26
else
  LINUX_TARGET:=linux2628
endif

ifeq ($(BUILD_VARIANT),ssl)
	SSL_FLAGS := USE_OPENSSL=1
endif

ifeq ($(BUILD_VARIANT),nossl)
	SSL_FLAGS := USE_OPENSSL=
endif

define Build/Compile
	$(MAKE) TARGET=$(LINUX_TARGET) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -fno-align-jumps -fno-align-functions -fno-align-labels -fno-align-loops -pipe -fomit-frame-pointer -fhonour-copts" \
		LD="$(TARGET_CC)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		PCREDIR="$(STAGING_DIR)/usr/include" \
		SMALL_OPTS="-DBUFSIZE=16384 -DMAXREWRITE=1030 -DSYSTEM_MAXCONN=165530 " \
		USE_LINUX_TPROXY=1 USE_LINUX_SPLICE=1 USE_REGPARM=1 $(SSL_FLAGS) \
		USE_ZLIB=yes USE_PCRE=1 \
		VERSION="$(PKG_VERSION)-patch$(PKG_RELEASE)" \
		install

	$(MAKE) -C $(PKG_BUILD_DIR)/contrib/halog \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -fno-align-jumps -fno-align-functions -fno-align-labels -fno-align-loops -pipe -fomit-frame-pointer -fhonour-copts" \
		LD="$(TARGET_CC)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
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

$(eval $(call BuildPackage,haproxy))
$(eval $(call BuildPackage,haproxy-nossl))
$(eval $(call BuildPackage,halog))
