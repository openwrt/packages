include $(TOPDIR)/rules.mk

PKG_NAME:=utr-lcd
PKG_VERSION:=0.1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/hryamzik/unifi/releases/download/v$(PKG_VERSION)
PKG_HASH:=b400d749a54141789f6a1b64efe7b3cc691afc2d9012a4a2c3920b16fb660e76

PKG_MAINTAINER:=Roman Belyakovsky <roman.beliakovskii@smartly.io>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/utr-lcd
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Status display for the UniFi Travel Router (UTR/UTR-LR) LCD
  DEPENDS:=@TARGET_ipq40xx +ubus +ubusd
endef

define Package/utr-lcd/description
  Shows Wi-Fi/Ethernet uplink, WAN IP, VPN, connected clients and uptime on the built-in
  136x240 LCD of the UniFi Travel Router. Works out of the box with a built-in renderer. If
  the user installs the optional stock bundle (made from their own Ubiquiti firmware) the
  original Ubiquiti-style UI is shown instead.
endef

define Package/utr-lcd/conffiles
/etc/config/utr-lcd
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/utr-lcd/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/files/utr-lcd.config $(1)/etc/config/utr-lcd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/utr-lcd.init $(1)/etc/init.d/utr-lcd
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin $(1)/usr/lib/utr-lcd $(1)/usr/libexec/utr-lcd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/utr-lcd-status $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/utr-lcd-fb2drm $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/utr-lcd-fbshim.so $(1)/usr/lib/utr-lcd/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/stock-install.sh $(1)/usr/sbin/utr-lcd-stock-install
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/collect.sh $(1)/usr/libexec/utr-lcd/collect.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/feed.sh $(1)/usr/libexec/utr-lcd/feed.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/traffic.sh $(1)/usr/libexec/utr-lcd/traffic.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/power.sh $(1)/usr/libexec/utr-lcd/power.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/ui-call.sh $(1)/usr/libexec/utr-lcd/ui-call.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/stock-run.sh $(1)/usr/libexec/utr-lcd/stock-run.sh
endef

$(eval $(call BuildPackage,utr-lcd))
