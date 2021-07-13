include $(TOPDIR)/rules.mk

PKG_NAME:=mdio-tools
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/wkz/mdio-tools
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2021-07-02
PKG_SOURCE_VERSION:=9f989622c21d5464168a4922542be044f21663b0
PKG_MIRROR_HASH:=9ae5d920e23a7957a5d5a8c5764969382ce6a174c5c5e7f7841fac0c81bbac75

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

$(eval $(call BuildPackage,mdio-tools))
