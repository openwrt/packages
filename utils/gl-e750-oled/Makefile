include $(TOPDIR)/rules.mk

PKG_NAME:=gl-e750-oled
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_MAINTAINER:=Serv Pol <servpol@w420.ru>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/gl-e750-oled
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=GL.iNet GL-E750 (Mudi) OLED status screen
  DEPENDS:=@TARGET_ath79 +kmod-gl-e750-mcu +ucode +ucode-mod-ubus \
	+ucode-mod-uloop +ucode-mod-uci +ucode-mod-fs
  PKGARCH:=all
endef

define Package/gl-e750-oled/description
  Shows Wi-Fi, clients, uplink, cellular and VPN state and the time on the
  OLED of the GL.iNet GL-E750 (Mudi). Reacts to netifd and hostapd events
  and hands the screen content to the kmod-gl-e750-mcu driver.
endef

define Package/gl-e750-oled/conffiles
/etc/config/gl-e750-oled
endef

define Build/Compile
endef

define Package/gl-e750-oled/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/gl-e750-oled.uc $(1)/usr/sbin/gl-e750-oled
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/gl-e750-oled.init $(1)/etc/init.d/gl-e750-oled
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/gl-e750-oled.config $(1)/etc/config/gl-e750-oled
endef

$(eval $(call BuildPackage,gl-e750-oled))
