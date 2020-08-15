include $(TOPDIR)/rules.mk

PKG_NAME:=hs20
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://w1.fi/hostap.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2020-06-08
PKG_SOURCE_VERSION:=5a8b366233f5585e68a4ffbb604fbb4a848eb325

PKG_SOURCE_NAME:=hostapd
PKG_MIRROR_HASH:=1b2a4947034142587a3f81eac2ea27dd64650e77f8943d973623b47533be2393
PKG_MIRROR_VERSION:=$(PKG_SOURCE_DATE)-$(call version_abbrev,$(PKG_SOURCE_VERSION))
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_MIRROR_VERSION).tar.xz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_SOURCE_NAME)-$(PKG_MIRROR_VERSION)

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=BSD-3-Clause
PKG_CPE_ID:=cpe:/a:w1.fi:hostapd

PKG_BUILD_PARALLEL:=1
PKG_ASLR_PIE_REGULAR:=1

ifdef CONFIG_USE_GLIBC
  TARGET_LDFLAGS += -lrt
  TARGET_LDFLAGS_C += -lrt
endif

include $(INCLUDE_DIR)/package.mk

define Package/hs20-client
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WirelessAPD
  TITLE:=Hotspot 2.0 OSU client
  URL:=http://hostap.epitest.fi/
  DEPENDS:=+libopenssl +libcurl +libxml2
endef

define Package/hs20-server
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WirelessAPD
  TITLE:=Hotspot 2.0 OSU server
  URL:=http://hostap.epitest.fi/
  DEPENDS:=+libopenssl +libsqlite3 +libxml2 +php7 +php7-cgi +php7-mod-xml +openssl-util +sqlite3-cli
endef

define Build/Configure
	cp "./files/hs20.config" "$(PKG_BUILD_DIR)/hostapd/.config"
endef

define Build/RunMake
	CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS)" \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/$(1) \
		$(TARGET_CONFIGURE_OPTS) \
		LIBS="$(TARGET_LDFLAGS) $(2)" \
		LIBS_c="$(TARGET_LDFLAGS_C)" \
		AR="$(TARGET_CROSS)gcc-ar" \
		BCHECK= CONFIG_NO_BROWSER=y \
		$(3)
endef

define Build/Compile
	$(call Build/RunMake,hostapd,-lssl -lcrypto -lsqlite3,hostapd hlr_auc_gw)
	$(call Build/RunMake,hs20/server,-lsqlite3 -lxml2,all)
	$(call Build/RunMake,hs20/client,-lssl -lcrypto -lcurl -lxml2,all)
endef

define Package/hs20-client/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hs20/client/hs20-osu-client $(1)/usr/sbin/
endef

define Package/hs20-server/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/share/hs20/ca $(1)/www/hs20
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hostapd/hostapd $(1)/usr/sbin/hostapd-hs20-radius-server
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hostapd/hlr_auc_gw $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hs20/server/hs20_spp_server $(1)/usr/sbin/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/hs20/server/www/* $(1)/www/hs20
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/hs20/server/*.txt $(1)/usr/share/hs20
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/hs20/server/ca/* $(1)/usr/share/hs20/ca
endef

$(eval $(call BuildPackage,hs20-client))
$(eval $(call BuildPackage,hs20-server))
