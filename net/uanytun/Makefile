#
# Copyright (C) 2008-2014 Christian Pointner,
#                         <equinox@anytun.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# This Makefile builds uAnytun Package for OpenWRT
#
# $Id: $

include $(TOPDIR)/rules.mk

PKG_NAME:=uanytun
PKG_VERSION:=0.3.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.anytun.org/download/
PKG_MD5SUM:=b4085ab7f0127732818b8b801f280aef

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk


define Package/uanytun/template
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  DEPENDS:=+kmod-tun
  TITLE:=micro anycast tunneling daemon
  URL:=http://www.anytun.org/
  MAINTAINER:=Christian Pointner <equinox@spreadspace.org>
endef


define Package/uanytun
  $(call Package/uanytun/template)
  TITLE+= (gcrypt)
  VARIANT:=gcrypt
  DEPENDS+=+libgcrypt
endef

define Package/uanytun/conffiles
/etc/config/uanytun
endef

define Package/uanytun/description
uAnytun is a tiny implementation of SATP the secure anycast tunneling protocol.
  SATP defines a protocol used for communication between any combination of
  unicast and anycast tunnel endpoints.  It has less protocol overhead than
  IPSec in Tunnel mode and allows tunneling of every ETHER TYPE protocol (e.g.
  ethernet, ip, arp ...). SATP directly includes cryptography and message
  authentication based on the methodes used by SRTP.  It is intended to deliver
  a generic, scaleable and secure solution for tunneling and relaying of packets
  of any protocol.
  Unlike Anytun which is a full featured implementation uAnytun has no support
  for multiple connections or synchronisation. It is a small single threaded
  implementation intended to act as a client on small platforms.
endef


define Package/uanytun-sslcrypt
  $(call Package/uanytun/template)
  TITLE+= (openssl)
  VARIANT:=sslcrypt
  DEPENDS+=+libopenssl
endef

Package/uanytun-sslcrypt/conffiles=$(Package/uanytun/conffiles)
Package/uanytun-sslcrypt/description=$(Package/uanytun/description)


define Package/uanytun-nocrypt
  $(call Package/uanytun/template)
  TITLE+= (no crypt)
  VARIANT:=nocrypt
endef

Package/uanytun-nocrypt/conffiles=$(Package/uanytun/conffiles)
Package/uanytun-nocrypt/description=$(Package/uanytun/description)



define Build/Configure
	(cd $(PKG_BUILD_DIR)/src; \
    touch include.mk; \
    ln -s linux/tun.c .; \
    echo '#ifndef UANYTUN_version_h_INCLUDED' > version.h; \
    echo '#define UANYTUN_version_h_INCLUDED' >> version.h; \
    echo '' >> version.h; \
    echo '#define VERSION_STRING_0 "uanytun version '`cat $(PKG_BUILD_DIR)/version`'"' >> version.h; \
    echo '#define VERSION_STRING_1 "built on '`hostname`', '`date +"%d.%m.%Y %H:%M:%S %Z"`'"' >> version.h; \
    echo '' >> version.h; \
    echo '#endif' >> version.h \
  )
endef

VARIANT_CFLAGS:=
VARIANT_LDFLAGS:=-ldl
VARIANT_MAKE_OPTS:=

ifeq ($(BUILD_VARIANT),gcrypt)
VARIANT_LDFLAGS+=-lgpg-error -lgcrypt
endif

ifeq ($(BUILD_VARIANT),sslcrypt)
VARIANT_CFLAGS+=-DUSE_SSL_CRYPTO
VARIANT_LDFLAGS+=-lcrypto
endif

ifeq ($(BUILD_VARIANT),nocrypt)
VARIANT_CFLAGS+=-DNO_CRYPT
VARIANT_MAKE_OPTS+=NO_CRYPT_OBJ=1
endif

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/src \
    $(TARGET_CONFIGURE_OPTS) \
    $(VARIANT_MAKE_OPTS) \
    TARGET=Linux \
    CFLAGS="$(TARGET_CFLAGS) $(VARIANT_CFLAGS)" \
    LDFLAGS="$(TARGET_LDFLAGS) $(VARIANT_LDFLAGS)"
	$(STRIP) $(PKG_BUILD_DIR)/src/uanytun
endef


define Package/uanytun/install-generic
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/$(2) $(1)/etc/config/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/uanytun $(1)/usr/sbin/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/uanytun.init $(1)/etc/init.d/$(PKG_NAME)
endef

define Package/uanytun/install
  $(call Package/uanytun/install-generic,$(1),uanytun.config)
endef

define Package/uanytun-sslcrypt/install
  $(call Package/uanytun/install-generic,$(1),uanytun.config)
endef

define Package/uanytun-nocrypt/install
  $(call Package/uanytun/install-generic,$(1),uanytun-nocrypt.config)
endef


$(eval $(call BuildPackage,uanytun))
$(eval $(call BuildPackage,uanytun-sslcrypt))
$(eval $(call BuildPackage,uanytun-nocrypt))
