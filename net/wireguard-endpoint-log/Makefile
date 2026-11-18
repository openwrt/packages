include $(TOPDIR)/rules.mk

PKG_NAME:=wireguard-endpoint-log
PKG_VERSION:=1.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/graysky2/WireGuard-Endpoint-Log/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=8ac448c9f1dbea29da647b00f21f2746b7f7fe43c7efa9434af42af10099028b

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/wireguard-endpoint-log
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=Log new WireGuard peer endpoints
  URL:=https://github.com/graysky2/WireGuard-Endpoint-Log
  DEPENDS:=+wireguard-tools +uclient-fetch +jsonfilter +ca-bundle
  PKGARCH:=all
endef

define Package/wireguard-endpoint-log/description
  Logs every new source endpoint observed for each WireGuard peer public key.
  By default, each new public endpoint address is looked up at ipinfo.io
  to log its ASN and location. Set the asn and geoip options to 0 in
  /etc/config/wireguard-endpoint-log to disable these lookups.
endef

define Package/wireguard-endpoint-log/conffiles
/etc/config/wireguard-endpoint-log
endef

define Build/Compile
endef

define Package/wireguard-endpoint-log/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wireguard-endpoint-log $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wireguard-endpoint-log.init $(1)/etc/init.d/wireguard-endpoint-log
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/wireguard-endpoint-log.config $(1)/etc/config/wireguard-endpoint-log
endef

$(eval $(call BuildPackage,wireguard-endpoint-log))
