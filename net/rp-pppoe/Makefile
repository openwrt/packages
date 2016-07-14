#
# Copyright (C) 2006-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rp-pppoe
PKG_VERSION:=3.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://roaringpenguin.com/files/download
PKG_MD5SUM:=216eb52b69062b92a64ee37fd71f4b66

PKG_BUILD_DEPENDS:=ppp

include $(INCLUDE_DIR)/package.mk

define Package/rp-pppoe/Default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+ppp
  TITLE:=PPPoE (PPP over Ethernet)
  URL:=http://roaringpenguin.com/products/pppoe
  SUBMENU:=dial-in/up
endef

define Package/rp-pppoe/Default/description
  Dubbed RP-PPPoE, this open-source product is ideal for Linux users with
  a DSL "modem" whose Internet service provider uses PPPoE.
endef

define Package/rp-pppoe-client
  $(call Package/rp-pppoe/Default)
  DEPENDS += @BROKEN
  TITLE+= client
endef

define Package/rp-pppoe-client/description
$(call Package/rp-pppoe/Default/description)
 .
 This package contains pppoe-connect.
endef

define Package/rp-pppoe-relay
  $(call Package/rp-pppoe/Default)
  TITLE+= relay
endef

define Package/rp-pppoe-relay/description
$(call Package/rp-pppoe/Default/description)
 .
 This package contains pppoe-relay.
endef

define Package/rp-pppoe-server
  $(call Package/rp-pppoe/Default)
  TITLE+= server
endef

define Package/rp-pppoe-server/conffiles
/etc/ppp/pppoe-server-options
/etc/default/pppoe-server
endef

define Package/rp-pppoe-server/description
$(call Package/rp-pppoe/Default/description)
 .
 This package contains pppoe-server.
endef

define Package/rp-pppoe-sniff
  $(call Package/rp-pppoe/Default)
  TITLE+= sniffer
endef

define Package/rp-pppoe-sniff/description
$(call Package/rp-pppoe/Default/description)
 .
 This package contains pppoe-sniff.
endef

TARGET_CFLAGS += -I$(PKG_BUILD_DIR)/src/libevent
CONFIGURE_PATH := ./src
CONFIGURE_ARGS += ac_cv_path_PPPD=/usr/sbin/pppd --enable-plugin=$(STAGING_DIR)/usr/include/
MAKE_FLAGS := DESTDIR="$(PKG_INSTALL_DIR)" install
MAKE_PATH := ./src

define Package/rp-pppoe-client/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/pppoe-client.init $(1)/etc/init.d/pppoe-client
	$(INSTALL_DIR) $(1)/etc/ppp
	$(CP) $(PKG_INSTALL_DIR)/etc/ppp/pppoe.conf $(1)/etc/ppp/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/pppoe $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/pppoe-connect $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/pppoe-start $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/pppoe-stop $(1)/usr/sbin/
	$(SED) 's,modprobe,insmod,g' $(1)/usr/sbin/pppoe-connect
endef

define Package/rp-pppoe-relay/install
	$(INSTALL_DIR) $(1)/etc/default
	$(INSTALL_BIN) ./files/pppoe-relay.default $(1)/etc/default/pppoe-relay
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/pppoe-relay.init $(1)/etc/init.d/pppoe-relay
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/pppoe-relay $(1)/usr/sbin/
endef

define Package/rp-pppoe-server/install
	$(INSTALL_DIR) $(1)/etc/default
	$(INSTALL_BIN) ./files/pppoe-server.default $(1)/etc/default/pppoe-server
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/pppoe-server.init $(1)/etc/init.d/pppoe-server
	$(INSTALL_DIR) $(1)/etc/ppp
	$(INSTALL_DIR) $(1)/etc/ppp/plugins
	$(CP) $(PKG_INSTALL_DIR)/etc/ppp/pppoe-server-options $(1)/etc/ppp/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/pppoe-server $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/etc/ppp/plugins/rp-pppoe.so $(1)/etc/ppp/plugins/
endef

define Package/rp-pppoe-sniff/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/pppoe-sniff $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,rp-pppoe-client))
$(eval $(call BuildPackage,rp-pppoe-relay))
$(eval $(call BuildPackage,rp-pppoe-server))
$(eval $(call BuildPackage,rp-pppoe-sniff))
