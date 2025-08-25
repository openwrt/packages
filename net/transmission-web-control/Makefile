include $(TOPDIR)/rules.mk

PKG_NAME:=transmission-web-control
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ronggang/transmission-web-control
PKG_SOURCE_DATE:=2024-04-08
PKG_SOURCE_VERSION:=f02a47aff2680de10c2269e22a3d0b37a318dbcd
PKG_MIRROR_HASH:=05e7422744dd3a23af58a3be6774b06ce7f2539b090aa0bb0dd1732e72267721

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
  TITLE:=A custom web UI for Transmission
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
