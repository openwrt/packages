include $(TOPDIR)/rules.mk

PKG_NAME:=gatling
PKG_VERSION:=0.16
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.fefe.de/gatling/
PKG_HASH:=5f96438ee201d7f1f6c2e0849ff273b196bdc7493f29a719ce8ed08c8be6365b

PKG_BUILD_DEPENDS:=px5g-mbedtls libowfat

PKG_MAINTAINER:=Martin Hübner <martin.hubner@web.de>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/gatling
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=gatling - a high performance web server
  URL:=https://www.fefe.de/gatling/
  DEPENDS:=+zlib +libcap +libopenssl
endef

define Package/gatling/description
  gatling - a high performance web server
  with a a rather small binary size but a decent set of extra features
  like ftp, basic htaccess and basic DoS-Protection.
  Gatling is particularly good in situations with very high load.
endef

define Package/gatling/conffiles
/etc/config/gatling
endef

define Package/gatling/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gatling $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/gatling.conf $(1)/etc/config/gatling

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/gatling.init $(1)/etc/init.d/gatling
endef

$(eval $(call BuildPackage,gatling))
