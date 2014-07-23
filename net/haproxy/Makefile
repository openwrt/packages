#
# Copyright (C) 2010-2013 OpenWrt.org
# Copyright (C) 2009-2014 Thomas Heil <heil@terminal-consulting.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=haproxy
PKG_VERSION:=1.5.2
PKG_RELEASE:=06
PKG_SOURCE:=haproxy-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://haproxy.1wt.eu/download/1.5/src/
PKG_MD5SUM:=e854fed32ea751d6db7f366cb910225a
PKG_MAINTAINER:=Thomas Heil <heil@terminal-consulting.de>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/haproxy
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  TITLE:=The Reliable, High Performance TCP/HTTP Load Balancer
  URL:=http://haproxy.1wt.eu/
  DEPENDS:=+libpcre +libltdl +libopenssl +zlib +libpthread
endef

define Package/haproxy/conffiles
/etc/haproxy.cfg
endef

define Package/haproxy/description
  Open source High Performance TCP/HTTP Load Balancer
endef

ifeq ($(CONFIG_avr32),y)
  LINUX_TARGET:=linux26
else
  LINUX_TARGET:=linux2628
endif

define Build/Compile
	$(MAKE) TARGET=$(LINUX_TARGET) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -fno-align-jumps -fno-align-functions -fno-align-labels -fno-align-loops -pipe -fomit-frame-pointer -fhonour-copts" \
		LD="$(TARGET_CC)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		ADDLIB="-lcrypto" \
		PCREDIR="$(STAGING_DIR)/usr/include" \
		SMALL_OPTS="-DBUFSIZE=16384 -DMAXREWRITE=1030 -DSYSTEM_MAXCONN=165530 " \
		USE_LINUX_TPROXY=1 USE_LINUX_SPLICE=1 USE_REGPARM=1 USE_OPENSSL=1 \
		USE_ZLIB=yes USE_PCRE=1 \
		VERSION="$(PKG_VERSION)-patch$(PKG_RELEASE)" \
		install

	$(MAKE) -C $(PKG_BUILD_DIR)/contrib/halog \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -fno-align-jumps -fno-align-functions -fno-align-labels -fno-align-loops -pipe -fomit-frame-pointer -fhonour-copts" \
		LD="$(TARGET_CC)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
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
$(eval $(call BuildPackage,halog))
