include $(TOPDIR)/rules.mk

PKG_NAME:=transmission-web-control
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ronggang/transmission-web-control
PKG_SOURCE_DATE:=2021-09-25
PKG_SOURCE_VERSION:=4b2e1858f7a46ee678d5d1f3fa1a6cf2c739b88a
PKG_MIRROR_HASH:=0134b0d03cfc0e0769a2e751caa307f2fd48639bab9bd4d2f3ab720ad04e6ced

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/transmission-web-control
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=BitTorrent
  DEPENDS:=+transmission-daemon
  CONFLICTS:=transmission-web
  TITLE:=Transmission Web Control
  URL:=https://github.com/ronggang/transmission-web-control
  PKGARCH:=all
endef

define Package/transmission-web-control/description
 Transmission Web Control is a custom Web UI for Transmission.
endef

define Build/Compile
endef

define Package/transmission-web-control/install
	$(INSTALL_DIR) $(1)/usr/share/transmission/public_html
	$(CP) $(PKG_BUILD_DIR)/src/* $(1)/usr/share/transmission/public_html
endef

$(eval $(call BuildPackage,transmission-web-control))
