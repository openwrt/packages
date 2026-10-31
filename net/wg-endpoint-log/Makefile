include $(TOPDIR)/rules.mk

PKG_NAME:=wg-endpoint-log
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/graysky2/wg-endpoint-log/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=8a59a09ac4fb95aed60331de6b55134b5e84d655fe71e355751e28ff3792ecb3

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/wireguard-endpoint-log
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=Log new WireGuard peer endpoints
  URL:=https://github.com/graysky2/wg-endpoint-log
  DEPENDS:=+wireguard-tools
  PKGARCH:=all
endef

define Package/wireguard-endpoint-log/description
  Logs every new source endpoint observed for each WireGuard peer public key.
endef

define Package/wireguard-endpoint-log/conffiles
/etc/config/wg-endpoint-log
endef

define Build/Compile
endef

define Package/wireguard-endpoint-log/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wg-endpoint-log $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wg-endpoint-log.init $(1)/etc/init.d/wg-endpoint-log
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/wg-endpoint-log.config $(1)/etc/config/wg-endpoint-log
endef

$(eval $(call BuildPackage,wireguard-endpoint-log))
