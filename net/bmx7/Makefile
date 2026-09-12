include $(TOPDIR)/rules.mk

PKG_NAME:=bmx7
PKG_VERSION:=2024.06.11
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/bmx-routing/bmx7.git
PKG_SOURCE_VERSION:=9020896f89006bc5d3487222eefc7ddea9e8b2bd
PKG_MIRROR_HASH:=a085904a48544d71ec815fa61c329925d89aca72a051941551290d292a6150d7

PKG_MAINTAINER:=Axel Neumann <axel@notmail.org>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += $(FPIC)

MAKE_ARGS += EXTRA_CFLAGS="$(TARGET_CFLAGS) \
				-I. \
				-I$(STAGING_DIR)/usr/include \
				-DCORE_LIMIT=20000 \
				-DTRAFFIC_DUMP \
				-DNO_TRACE_FUNCTION_CALLS \
				-DBMX7_LIB_IWINFO" \
				EXTRA_LDFLAGS="$(TARGET_LDFLAGS) \
			 	-L$(STAGING_DIR)/usr/lib -liwinfo" \
				CC="$(TARGET_CC)" \
				INSTALL_DIR="$(PKG_INSTALL_DIR)" \
				build_all

MAKE_PATH:=src

define Package/bmx7/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=BMX7 layer 3 routing daemon
  URL:=https://github.com/bmx-routing/bmx7
  DEPENDS:=+zlib +libmbedtls +libiwinfo
endef

define Package/bmx7/description
  BMX7 routing daemon supporting securely-entrusted IPv6 (and IPv4in6) routing
endef

define Package/bmx7
  $(call Package/bmx7/Default)
  MENU:=1
endef

define Package/bmx7-uci-config
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7 +libuci
  TITLE:=configuration plugin based on uci (recommended!)
endef

define Package/bmx7-iwinfo
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7 +libiwinfo
  TITLE:=link characteristics plugin via libiwinfo (recommended!)
endef

define Package/bmx7-topology
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7
  TITLE:=topology plugin
endef

define Package/bmx7-json
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7 +libjson-c
  TITLE:=json plugin based on json-c
endef

define Package/bmx7-sms
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7
  TITLE:=sms plugin
endef

define Package/bmx7-tun
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7 +kmod-ip6-tunnel +kmod-iptunnel6 +kmod-tun
  TITLE:=ipip-based tunnel plugin (recommended!)
endef

define Package/bmx7-table
  $(call Package/bmx7/Default)
  DEPENDS:=bmx7 +bmx7-tun
  TITLE:=plugin to announce routes from tables via tunnels
endef

define Package/bmx7/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(MAKE_PATH)/bmx7 $(1)/usr/sbin/bmx7
endef

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/$(MAKE_PATH) $(MAKE_ARGS)
endef

define Package/bmx7-uci-config/conffiles
/etc/config/bmx7
/etc/bmx7/
endef

define Package/bmx7-uci-config/install
	$(INSTALL_DIR) $(1)/usr/lib $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(MAKE_PATH)/lib/bmx7_uci_config/bmx7_config.so \
		$(1)/usr/lib/bmx7_config.so
	$(INSTALL_BIN) ./files/etc/init.d/bmx7 $(1)/etc/init.d/bmx7
	$(INSTALL_CONF) ./files/etc/config/bmx7 $(1)/etc/config/bmx7
endef

define Package/bmx7-iwinfo/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(MAKE_PATH)/lib/bmx7_iwinfo/bmx7_iwinfo.so \
		$(1)/usr/lib/bmx7_iwinfo.so
endef

define Package/bmx7-topology/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(MAKE_PATH)/lib/bmx7_topology/bmx7_topology.so \
		$(1)/usr/lib/bmx7_topology.so
endef

define Package/bmx7-json/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(MAKE_PATH)/lib/bmx7_json/bmx7_json.so \
		$(1)/usr/lib/bmx7_json.so
endef

define Package/bmx7-sms/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(MAKE_PATH)/lib/bmx7_sms/bmx7_sms.so \
		$(1)/usr/lib/bmx7_sms.so
endef

define Package/bmx7-tun/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(MAKE_PATH)/lib/bmx7_tun/bmx7_tun.so \
		$(1)/usr/lib/bmx7_tun.so
endef

define Package/bmx7-table/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(MAKE_PATH)/lib/bmx7_table/bmx7_table.so \
		$(1)/usr/lib/bmx7_table.so
endef

$(eval $(call BuildPackage,bmx7))
$(eval $(call BuildPackage,bmx7-uci-config))
$(eval $(call BuildPackage,bmx7-iwinfo))
$(eval $(call BuildPackage,bmx7-topology))
$(eval $(call BuildPackage,bmx7-json))
$(eval $(call BuildPackage,bmx7-sms))
$(eval $(call BuildPackage,bmx7-table))
$(eval $(call BuildPackage,bmx7-tun))
