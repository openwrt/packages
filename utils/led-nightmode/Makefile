include $(TOPDIR)/rules.mk

PKG_NAME:=led-nightmode
PKG_VERSION:=0.5.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Mv Go <rapture-ribose6k@icloud.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=luci-app-led-nightmode-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/mv-go/luci-app-led-nightmode/archive/refs/tags/v$(PKG_VERSION).tar.gz?
PKG_HASH:=7e7af0c3e6970f47f1af975863ede0339f359a3fafce7d6cdc637e168305c4cc
PKG_BUILD_DIR:=$(BUILD_DIR)/luci-app-led-nightmode-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Compile
endef

define Package/led-nightmode
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=LED night mode runtime for OpenWrt
  DEPENDS:=+jshn +procd +rpcd +sunwait +uci
  PKGARCH:=all
  URL:=https://github.com/mv-go/luci-app-led-nightmode
endef

define Package/led-nightmode/description
  Discovers Linux LED class devices at runtime, preserves their original
  triggers and brightness, and applies reversible day and night profiles.
endef

define Package/led-nightmode/conffiles
/etc/config/led-nightmode
endef

define Package/led-nightmode/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/core/root/etc/config/led-nightmode $(1)/etc/config/led-nightmode
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/root/etc/init.d/led-nightmode $(1)/etc/init.d/led-nightmode
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/root/etc/uci-defaults/99-led-nightmode $(1)/etc/uci-defaults/99-led-nightmode
	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/root/usr/libexec/led-nightmode-provider-service $(1)/usr/libexec/led-nightmode-provider-service
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/root/usr/libexec/led-nightmode-service $(1)/usr/libexec/led-nightmode-service
	$(LN) led-nightmode-service $(1)/usr/libexec/led-nightmode-schedule
	$(LN) ../led-nightmode-service $(1)/usr/libexec/rpcd/luci.led-nightmode
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/core/root/usr/sbin/led-nightmode $(1)/usr/sbin/led-nightmode
endef

define Package/led-nightmode/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || /etc/init.d/rpcd reload 2>/dev/null
exit 0
endef

$(eval $(call BuildPackage,led-nightmode))
