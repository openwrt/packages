include $(TOPDIR)/rules.mk

PKG_NAME:=mdio-tools
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_RELEASE:=$(AUTORELEASE)
PKG_SOURCE_URL:=https://github.com/wkz/mdio-tools
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2021-07-02
PKG_SOURCE_VERSION:=9f989622c21d5464168a4922542be044f21663b0
PKG_MIRROR_HASH:=9feaeaad48dd81cf9c6e441ace86d3a44139b8a5326fac2f8751a0666b4eb6db

PKG_FIXUP:=autoreconf

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=LICENSE

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

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -Wall" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/mdio-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mdio/mdio $(1)/usr/bin/
endef

$(eval $(call BuildPackage,mdio-tools))
