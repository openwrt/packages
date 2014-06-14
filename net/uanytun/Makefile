#
# Copyright (C) 2008 Christian Pointner,
#                    <equinox@anytun.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# This Makefile builds uAnytun Package for OpenWRT
#
# $Id: $

include $(TOPDIR)/rules.mk

PKG_NAME:=uanytun
PKG_VERSION:=0.3.3
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.anytun.org/download/
PKG_MD5SUM:=ca39dab02e91b0737e2b3f0839e74f6a

include $(INCLUDE_DIR)/package.mk


define Package/uanytun/template
  SECTION:=net
  CATEGORY:=Network
  TITLE:=micro anycast tunneling daemon
  URL:=http://www.anytun.org/
  MAINTAINER:=Christian Pointner <equinox@anytun.org>
  SUBMENU:=VPN
endef

define Package/uanytun/desc-template
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


define Package/uanytun
  $(call Package/uanytun/template)
  DEPENDS:=+kmod-tun +libgcrypt
endef

define Package/uanytun/conffiles
/etc/config/uanytun
endef

define Package/uanytun/description
  $(call Package/uanytun/desc-template)
endef


define Package/uanytun-sslcrypt
  $(call Package/uanytun/template)
  DEPENDS:=+kmod-tun +libopenssl
endef

define Package/uanytun-sslcrypt/conffiles
/etc/config/uanytun-sslcrypt
endef

define Package/uanytun-sslcrypt/description
  $(call Package/uanytun/desc-template)
endef


define Package/uanytun-nocrypt
  $(call Package/uanytun/template)
  DEPENDS:=+kmod-tun
endef

define Package/uanytun-nocrypt/conffiles
/etc/config/uanytun-nocrypt
endef

define Package/uanytun-nocrypt/description
  $(call Package/uanytun/desc-template)
endef

define Package/uanytun/configure
	(cd $(1)/$(2)/src; \
    touch include.mk; \
    ln -s linux/tun.c .; \
    echo '#ifndef UANYTUN_version_h_INCLUDED' > version.h; \
    echo '#define UANYTUN_version_h_INCLUDED' >> version.h; \
    echo '' >> version.h; \
    echo '#define VERSION_STRING_0 "uanytun version '`cat $(1)/version`'"' >> version.h; \
    echo '#define VERSION_STRING_1 "built on '`hostname`', '`date +"%d.%m.%Y %H:%M:%S %Z"`'"' >> version.h; \
    echo '' >> version.h; \
    echo '#endif' >> version.h \
  )
endef

ifneq ($(CONFIG_PACKAGE_uanytun-nocrypt),)
 define Build/Configure/uanytun-nocrypt
	rm -rf $(PKG_BUILD_DIR)/uanytun-nocrypt
	mkdir -p $(PKG_BUILD_DIR)/uanytun-nocrypt
	$(CP) -r $(PKG_BUILD_DIR)/src $(PKG_BUILD_DIR)/uanytun-nocrypt
	$(call Package/uanytun/configure,$(PKG_BUILD_DIR),uanytun-nocrypt)
 endef

 define Build/Compile/uanytun-nocrypt
	$(MAKE) -C $(PKG_BUILD_DIR)/uanytun-nocrypt/src \
    $(TARGET_CONFIGURE_OPTS) \
    NO_CRYPT_OBJ=1 \
    TARGET=Linux \
    CFLAGS="$(TARGET_CFLAGS) -DNO_CRYPT" \
    LDFLAGS="$(TARGET_LDFLAGS) -ldl"
	$(STRIP) $(PKG_BUILD_DIR)/uanytun-nocrypt/src/uanytun
 endef
endif

ifneq ($(CONFIG_PACKAGE_uanytun-sslcrypt),)
 define Build/Configure/uanytun-sslcrypt
	rm -rf $(PKG_BUILD_DIR)/uanytun-sslcrypt
	mkdir -p $(PKG_BUILD_DIR)/uanytun-sslcrypt
	$(CP) -r $(PKG_BUILD_DIR)/src $(PKG_BUILD_DIR)/uanytun-sslcrypt
	$(call Package/uanytun/configure,$(PKG_BUILD_DIR),uanytun-sslcrypt)
 endef

 define Build/Compile/uanytun-sslcrypt
	$(MAKE) -C $(PKG_BUILD_DIR)/uanytun-sslcrypt/src \
    $(TARGET_CONFIGURE_OPTS) \
    TARGET=Linux \
    CFLAGS="$(TARGET_CFLAGS) -DUSE_SSL_CRYPTO -I$(STAGING_DIR)/usr/include" \
    LDFLAGS="$(TARGET_LDFLAGS) -ldl -lcrypto"
	$(STRIP) $(PKG_BUILD_DIR)/uanytun-sslcrypt/src/uanytun
 endef
endif

ifneq ($(CONFIG_PACKAGE_uanytun),)
 define Build/Configure/uanytun-default
	rm -rf $(PKG_BUILD_DIR)/uanytun
	mkdir -p $(PKG_BUILD_DIR)/uanytun
	$(CP) -r $(PKG_BUILD_DIR)/src $(PKG_BUILD_DIR)/uanytun
	$(call Package/uanytun/configure,$(PKG_BUILD_DIR),uanytun)
 endef

 define Build/Compile/uanytun-default
	$(MAKE) -C $(PKG_BUILD_DIR)/uanytun/src \
    $(TARGET_CONFIGURE_OPTS) \
    TARGET=Linux \
    CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include" \
    LDFLAGS="$(TARGET_LDFLAGS) -ldl -lgcrypt -lgpg-error"
	$(STRIP) $(PKG_BUILD_DIR)/uanytun/src/uanytun
 endef
endif


define Build/Configure
	$(call Build/Configure/uanytun-nocrypt)
	$(call Build/Configure/uanytun-sslcrypt)
	$(call Build/Configure/uanytun-default)
endef

define Build/Compile
	$(call Build/Compile/uanytun-nocrypt)
	$(call Build/Compile/uanytun-sslcrypt)
	$(call Build/Compile/uanytun-default)
endef

define Build/Clean
	rm -rf $(PKG_BUILD_DIR)/uanytun-nocrypt
	rm -rf $(PKG_BUILD_DIR)/uanytun-sslcrypt
	rm -rf $(PKG_BUILD_DIR)/uanytun
endef



define Package/uanytun/install-generic
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/$(3) $(1)/etc/config/$(2)
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(2)/src/uanytun $(1)/usr/sbin/$(2)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/uanytun.init $(1)/etc/init.d/$(2)
	@sed -e 's/BIN=uanytun/BIN=$(2)/' -i $(1)/etc/init.d/$(2)
endef

define Package/uanytun/install
  $(call Package/uanytun/install-generic,$(1),uanytun,uanytun.config)
endef

define Package/uanytun-sslcrypt/install
  $(call Package/uanytun/install-generic,$(1),uanytun-sslcrypt,uanytun.config)
endef

define Package/uanytun-nocrypt/install
  $(call Package/uanytun/install-generic,$(1),uanytun-nocrypt,uanytun-nocrypt.config)
endef



$(eval $(call BuildPackage,uanytun))
$(eval $(call BuildPackage,uanytun-sslcrypt))
$(eval $(call BuildPackage,uanytun-nocrypt))
