#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rp-pppoe
PKG_VERSION:=3.12
PKG_RELEASE:=1
PKG_MAINTAINER:=Luke McKee <hojuruku@gmail.com>
PKG_LICENSE:=GPL
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://roaringpenguin.com/files/download
PKG_MD5SUM:=216eb52b69062b92a64ee37fd71f4b66

PKG_BUILD_DEPENDS:=ppp
PKG_DEPENDS:=ppp ppp-mod-pppoe
PPPD_VERSION:=2.4.7

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/rp-pppoe/Default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+ppp
  TITLE:=PPPoE Server (PPP over Ethernet)
  URL:=http://roaringpenguin.com/products/pppoe
endef

define Package/rp-pppoe/Default/description
	This package provides a PPPOE server if you are running an Access Concentrator (ISP).
	RP-PPPOE Kernel mode client often used for broadband connections is now bundled with the ppp daemon
	pppd plugin rp-pppoe.so is also needed to run this pppoe server in kernel mode (-k).
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
#-DPLUGIN_PATH=\"/usr/lib/pppd/$(PPPD_VERSION)/rp-pppoe.so\"
CONFIGURE_PATH := ./src
CONFIGURE_ARGS += ac_cv_path_PPPD=/usr/sbin/pppd ac_cv_linux_kernel_pppoe=yes ac_cv_pluginpath=no
MAKE_FLAGS := DESTDIR="$(PKG_INSTALL_DIR)" PPPD_VERSION=$(PPPD_VERSION) install
MAKE_PATH := ./src

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
	$(CP) $(PKG_INSTALL_DIR)/etc/ppp/pppoe-server-options $(1)/etc/ppp/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/pppoe-server $(1)/usr/sbin/
endef

define Package/rp-pppoe-sniff/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/pppoe-sniff $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,rp-pppoe-relay))
$(eval $(call BuildPackage,rp-pppoe-server))
$(eval $(call BuildPackage,rp-pppoe-sniff))
