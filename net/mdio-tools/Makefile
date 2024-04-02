include $(TOPDIR)/rules.mk

PKG_NAME:=mdio-tools
PKG_VERSION:=1.3.1
PKG_RELEASE:=2

PKG_SOURCE_URL:=https://github.com/wkz/mdio-tools
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=f74eaf38dbda441df4fcaeb21ca4465957953a2f
PKG_MIRROR_HASH:=b7973284dc3dffef4bd2a904e3f7aa7fd3caab4aecf85ac57488f5acbf341aba

PKG_FIXUP:=autoreconf

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=Damien Mascord <tusker@tusker.org>

include $(INCLUDE_DIR)/package.mk

define Package/mdio-tools
  SECTION:=net
  CATEGORY:=Utilities
  TITLE:=mdio-tools Linux MDIO register access
  URL:=https://github.com/wkz/mdio-tools.git
  DEPENDS:=+kmod-mdio-netlink +libmnl
endef

define Package/mdio-tools/description
  mdio-tools Linux MDIO register access
endef

define Package/mdio-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mdio/mdio $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mvls/mvls $(1)/usr/bin/
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED) 's/m4_esyscmd_s(.*)/$(PKG_VERSION)/' $(PKG_BUILD_DIR)/configure.ac
endef

$(eval $(call BuildPackage,mdio-tools))
