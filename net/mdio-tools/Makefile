include $(TOPDIR)/rules.mk

PKG_NAME:=mdio-tools
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/wkz/mdio-tools
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=1.0.1
PKG_MIRROR_HASH:=36bc20b91034a2bbc627a4d4b58c3b46279f5bb65bf2067347a751bb0f9a0371

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
  DEPENDS:=+libmnl
endef

define Package/mdio-tools/description
  mdio-tools Linux MDIO register access
endef

define Package/mdio-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mdio/mdio $(1)/usr/bin/
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED) 's/m4_esyscmd_s(.*)/$(PKG_VERSION)/' $(PKG_BUILD_DIR)/configure.ac
endef

$(eval $(call BuildPackage,mdio-tools))
