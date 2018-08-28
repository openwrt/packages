#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nodogsplash
PKG_FIXUP:=autoreconf
PKG_VERSION:=3.1.0
PKG_RELEASE:=0

PKG_SOURCE_URL:=https://codeload.github.com/nodogsplash/nodogsplash/tar.gz/v$(PKG_VERSION)?
PKG_SOURCE:=nodogsplash-$(PKG_VERSION).tar.gz
PKG_HASH:=07363f76de6ca5bde5e98f5218e67150164174d2117936b3d57ac7ab01e7b413
PKG_BUILD_DIR:=$(BUILD_DIR)/nodogsplash-$(PKG_VERSION)

PKG_MAINTAINER:=Moritz Warning <moritzwarning@web.de>
PKG_BUILD_PARALLEL:=1
PKG_LICENSE:=GPL-2.0+

include $(INCLUDE_DIR)/package.mk


define Package/nodogsplash
	SUBMENU:=Captive Portals
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+libpthread +iptables-mod-ipopt +libmicrohttpd-no-ssl
	TITLE:=Open public network gateway daemon
	URL:=https://github.com/nodogsplash/nodogsplash
	CONFLICTS:=nodogsplash2
endef

define Package/nodogsplash/description
	Nodogsplash offers a simple way to open a free hotspot providing
	restricted access to an internet connection.
endef

define Package/nodogsplash/install
	$(CP) ./files/* $(1)/

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nodogsplash $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ndsctl $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/nodogsplash/htdocs/images
	$(CP) $(PKG_BUILD_DIR)/resources/splash.html $(1)/etc/nodogsplash/htdocs/
	$(CP) $(PKG_BUILD_DIR)/resources/status.html $(1)/etc/nodogsplash/htdocs/
	$(CP) $(PKG_BUILD_DIR)/resources/splash.jpg $(1)/etc/nodogsplash/htdocs/images/
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
