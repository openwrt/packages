include $(TOPDIR)/rules.mk

PKG_NAME:=i2csfp
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2024-06-16
PKG_SOURCE_VERSION:=da2c7582933d0eb76bad1c86d1252d200a702596
PKG_SOURCE_URL:=https://github.com/ericwoud/i2csfp
PKG_MIRROR_HASH:=4cf100018e7c8510f334b9f14968a063a3cabc3b505d4b4abe1f11e2b74389ae

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
