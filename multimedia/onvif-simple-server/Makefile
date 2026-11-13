# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=onvif-simple-server
PKG_VERSION:=2026.10.17
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/roleoroleo/onvif_simple_server.git
PKG_SOURCE_DATE:=2026-10-17
PKG_SOURCE_VERSION:=40fd1086f2e32ac91aff58647aeb21ed2a8a76b7
PKG_MIRROR_HASH:=53e14bed1d28ffecec3da0e26e722309ddd43ca97bbc49b448a30abcfb6cfe7c

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/onvif-simple-server
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=ONVIF CGI services and WS-Discovery
  URL:=https://github.com/roleoroleo/onvif_simple_server
  DEPENDS:=+libmbedtls +libjson-c +zlib +uhttpd +ucode +ucode-mod-fs +ucode-mod-uci
endef

define Package/onvif-simple-server/description
  ONVIF Device, Media, Media2 and optional Imaging services served as CGI
  through uhttpd. Includes WS-Discovery and generic external control helpers.
endef

define Package/onvif-simple-server/conffiles
/etc/config/onvif-simple-server
endef

MAKE_FLAGS += \
	HAVE_MBEDTLS=1 \
	CC="$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(TARGET_LDFLAGS)" \
	STRIP=true

define Build/Configure
endef

define Package/onvif-simple-server/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/share/onvif-simple-server
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/onvif_simple_server $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wsd_simple_server $(1)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/*_files $(1)/usr/share/onvif-simple-server/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/CONTROL_HELPERS.md $(1)/usr/share/onvif-simple-server/
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d $(1)/etc/uci-defaults
	$(INSTALL_CONF) ./files/onvif.config $(1)/etc/config/onvif-simple-server
	$(INSTALL_BIN) ./files/onvif.init $(1)/etc/init.d/onvif-simple-server
	$(INSTALL_BIN) ./files/onvif.defaults $(1)/etc/uci-defaults/80-onvif-simple-server
	$(INSTALL_DIR) $(1)/www/onvif/onvif
	$(INSTALL_BIN) ./files/onvif.cgi $(1)/www/onvif/onvif/device_service
	$(foreach service,media media2 imaging deviceio events ptz, \
		$(LN) device_service $(1)/www/onvif/onvif/$(service)_service;)
endef

$(eval $(call BuildPackage,onvif-simple-server))
