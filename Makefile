# 
# Copyright (C) 2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=olsrd
PKG_VERSION:=0.5.6-r8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.olsr.org/releases/0.5
PKG_MD5SUM:=aef6f4350c44fd0ad015a26621ef9607

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += $(FPIC)

define Package/olsrd/template
  SECTION:=net
  CATEGORY:=Network
  TITLE:=OLSR (Optimized Link State Routing) daemon
  URL:=http://www.olsr.org/
endef

define Package/olsrd
  $(call Package/olsrd/template)
  MENU:=1
  DEPENDS:=+libpthread
endef

define Package/olsrd/conffiles
/etc/config/olsrd
endef

define Package/olsrd-mod-arprefresh
  $(call Package/olsrd/template)
  DEPENDS:=olsrd
  TITLE:=Kernel ARP cache refresh plugin
endef

define Package/olsrd-mod-dot-draw
  $(call Package/olsrd/template)
  DEPENDS:=olsrd
  TITLE:=Dot topology information plugin
endef

define Package/olsrd-mod-bmf
  $(call Package/olsrd/template)
  DEPENDS:=olsrd +kmod-tun
  TITLE:=Basic multicast forwarding plugin
endef

define Package/olsrd-mod-dyn-gw
  $(call Package/olsrd/template)
  DEPENDS:=olsrd
  TITLE:=Dynamic internet gateway plugin
endef

define Package/olsrd-mod-dyn-gw-plain
  $(call Package/olsrd/template)
  DEPENDS:=olsrd
  TITLE:=Dynamic internet gateway plain plugin
endef

define Package/olsrd-mod-httpinfo
  $(call Package/olsrd/template)
  DEPENDS:=olsrd
  TITLE:=Small informative web server plugin
endef

define Package/olsrd-mod-nameservice
  $(call Package/olsrd/template)
  DEPENDS:=olsrd
  TITLE:=Lightweight hostname resolver plugin
endef

define Package/olsrd-mod-quagga
  $(call Package/olsrd/template)
  DEPENDS:=olsrd
  TITLE:=Quagga plugin
endef

define Package/olsrd-mod-secure
  $(call Package/olsrd/template)
  DEPENDS:=olsrd
  TITLE:=Message signing plugin to secure routing domain
endef

define Package/olsrd-mod-txtinfo
  $(call Package/olsrd/template)
  DEPENDS:=olsrd
  TITLE:=Small informative web server plugin
endef

define Package/olsrd-mod-watchdog
  $(call Package/olsrd/template)
  DEPENDS:=olsrd
  TITLE:=Watchdog plugin
endef

define Package/olsrd-mod-secure/conffiles
/etc/olsrd.d/olsrd_secure_key
endef

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C "$(PKG_BUILD_DIR)" \
		$(TARGET_CONFIGURE_OPTS) \
		NODEBUG=1 \
		CFLAGS="$(TARGET_CFLAGS)" \
		OS="linux" \
		INSTALL_PREFIX="$(PKG_INSTALL_DIR)" \
		LIBDIR="$(PKG_INSTALL_DIR)/usr/lib" \
		SBINDIR="$(PKG_INSTALL_DIR)/usr/sbin/" \
		ETCDIR="$(PKG_INSTALL_DIR)/etc" \
		MANDIR="$(PKG_INSTALL_DIR)/usr/share/man" \
		STRIP="true" \
		INSTALL_LIB="true" \
		SUBDIRS="arprefresh bmf dot_draw dyn_gw dyn_gw_plain httpinfo nameservice quagga secure txtinfo watchdog" \
		all libs install install_libs
endef

define Package/olsrd/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/olsrd.config $(1)/etc/config/olsrd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/olsrd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/olsrd.init $(1)/etc/init.d/olsrd
endef

define Package/olsrd-mod-arprefresh/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/arprefresh/olsrd_arprefresh.so.* $(1)/usr/lib/
endef

define Package/olsrd-mod-dot-draw/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/dot_draw/olsrd_dot_draw.so.* $(1)/usr/lib/
endef

define Package/olsrd-mod-bmf/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/bmf/olsrd_bmf.so.* $(1)/usr/lib/
endef

define Package/olsrd-mod-dyn-gw/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/dyn_gw/olsrd_dyn_gw.so.* $(1)/usr/lib/
endef

define Package/olsrd-mod-dyn-gw-plain/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/dyn_gw_plain/olsrd_dyn_gw_plain.so.* $(1)/usr/lib/
endef

define Package/olsrd-mod-httpinfo/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/httpinfo/olsrd_httpinfo.so.* $(1)/usr/lib/
endef

define Package/olsrd-mod-nameservice/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/nameservice/olsrd_nameservice.so.* $(1)/usr/lib/
endef

define Package/olsrd-mod-quagga/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/quagga/olsrd_quagga.so.* $(1)/usr/lib/
endef

define Package/olsrd-mod-secure/install
	$(INSTALL_DIR) $(1)/etc/olsrd.d
	$(CP) ./files/olsrd_secure_key $(1)/etc/olsrd.d/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/secure/olsrd_secure.so.* $(1)/usr/lib/
endef

define Package/olsrd-mod-txtinfo/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/txtinfo/olsrd_txtinfo.so.* $(1)/usr/lib/
endef

define Package/olsrd-mod-watchdog/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib/watchdog/olsrd_watchdog.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,olsrd))
$(eval $(call BuildPackage,olsrd-mod-arprefresh))
$(eval $(call BuildPackage,olsrd-mod-dot-draw))
$(eval $(call BuildPackage,olsrd-mod-bmf))
$(eval $(call BuildPackage,olsrd-mod-dyn-gw))
$(eval $(call BuildPackage,olsrd-mod-dyn-gw-plain))
$(eval $(call BuildPackage,olsrd-mod-httpinfo))
$(eval $(call BuildPackage,olsrd-mod-nameservice))
$(eval $(call BuildPackage,olsrd-mod-quagga))
$(eval $(call BuildPackage,olsrd-mod-secure))
$(eval $(call BuildPackage,olsrd-mod-txtinfo))
$(eval $(call BuildPackage,olsrd-mod-watchdog))
