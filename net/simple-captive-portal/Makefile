include $(TOPDIR)/rules.mk

PKG_NAME:=simple-captive-portal
PKG_VERSION:=2025.06.22
PKG_RELEASE:=1

PKG_MAINTAINER:=Etienne CHAMPETIER <champetier.etienne@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk

Build/Compile=

define Package/simple-captive-portal
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Simple captive portal
  PKGARCH:=all
  DEPENDS:=+uhttpd +uhttpd-mod-lua +luci-lib-ip
endef

define Package/simple-captive-portal/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/simple-captive-portal $(1)/etc/config/simple-captive-portal
	$(INSTALL_DIR) $(1)/etc/hotplug.d/net/
	$(INSTALL_DATA) ./files/etc/hotplug.d/net/00-simple-captive-portal $(1)/etc/hotplug.d/net/00-simple-captive-portal
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/simple-captive-portal $(1)/etc/init.d/simple-captive-portal
	$(INSTALL_DIR) $(1)/etc/simple-captive-portal/
	$(INSTALL_DATA) ./files/etc/simple-captive-portal/index.html $(1)/etc/simple-captive-portal/index.html
	$(INSTALL_DATA) ./files/etc/simple-captive-portal/connected.html $(1)/etc/simple-captive-portal/connected.html
	$(INSTALL_DIR) $(1)/usr/share/simple-captive-portal/
	$(INSTALL_DATA) ./files/usr/share/simple-captive-portal/capabilities.json $(1)/usr/share/simple-captive-portal/capabilities.json
	$(INSTALL_DATA) ./files/usr/share/simple-captive-portal/portal.lua $(1)/usr/share/simple-captive-portal/portal.lua
	$(INSTALL_DATA) ./files/usr/share/simple-captive-portal/redirect.lua $(1)/usr/share/simple-captive-portal/redirect.lua
endef

define Package/simple-captive-portal/conffiles
/etc/simple-captive-portal/
/etc/config/simple-captive-portal
endef

define Package/simple-captive-portal/description
  Provides a simple captive portal splash page.
endef

$(eval $(call BuildPackage,simple-captive-portal))
