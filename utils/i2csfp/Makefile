include $(TOPDIR)/rules.mk

PKG_NAME:=i2csfp
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2026-01-08
PKG_SOURCE_VERSION:=95df5e68b46d89dbd32d184d09c17b45b2a6e7fb
PKG_SOURCE_URL:=https://github.com/ericwoud/i2csfp
PKG_MIRROR_HASH:=e542f46d4938a982a52765ea547181681acf7363cc4928fc31fd8d8144261ffa

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

include $(INCLUDE_DIR)/package.mk

define Package/i2csfp
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=I2C SFP utility
endef

define Package/i2csfp/description
  A user-space program to access sfp module via i2c.
endef

define Build/Configure
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) -Wall \
		-o $(PKG_BUILD_DIR)/i2csfp $(PKG_BUILD_DIR)/i2csfp.c $(TARGET_LDFLAGS)
endef

define Package/i2csfp/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/i2csfp $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,i2csfp))
