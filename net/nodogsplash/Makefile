#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nodogsplash
PKG_VERSION:=5.0.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/nodogsplash/nodogsplash/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=908d3674e93726fdcefb4c3b6705c745753435df9d46425781a57e3f6b417797

PKG_MAINTAINER:=Moritz Warning <moritzwarning@web.de>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/nodogsplash
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpthread +libmicrohttpd-no-ssl +iptables-nft \
           +iptables-mod-nat-extra +iptables-mod-ipopt \
           +iptables-mod-conntrack-extra
  TITLE:=Open public network gateway daemon
  URL:=https://github.com/nodogsplash/nodogsplash
endef

define Package/nodogsplash/description
  Nodogsplash is a Captive Portal that offers a simple way to
  provide restricted access to the Internet by showing a splash
  page to the user before Internet access is granted.
endef

define Package/nodogsplash/install
	$(INSTALL_DIR) $(1)/usr/lib/nodogsplash
	$(INSTALL_BIN) ./files/usr/lib/nodogsplash/restart.sh $(1)/usr/lib/nodogsplash/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nodogsplash $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ndsctl $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/nodogsplash/htdocs/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/resources/splash.html $(1)/etc/nodogsplash/htdocs/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/resources/splash.css $(1)/etc/nodogsplash/htdocs/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/resources/status.html $(1)/etc/nodogsplash/htdocs/
	$(INSTALL_DIR) $(1)/etc/nodogsplash/htdocs/images
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/resources/splash.jpg $(1)/etc/nodogsplash/htdocs/images/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/nodogsplash $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/nodogsplash $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/40_nodogsplash $(1)/etc/uci-defaults/
endef

define Package/nodogsplash/postrm
#!/bin/sh
uci delete firewall.nodogsplash
uci commit firewall
endef

define Package/nodogsplash/conffiles
/etc/config/nodogsplash
endef

$(eval $(call BuildPackage,nodogsplash))
