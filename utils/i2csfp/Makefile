include $(TOPDIR)/rules.mk

PKG_NAME:=i2csfp
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2025-08-05
PKG_SOURCE_VERSION:=1b9b4e0f4a93c266d88ddfac327299eabeb23b60
PKG_SOURCE_URL:=https://github.com/ericwoud/i2csfp
PKG_MIRROR_HASH:=4200c23b07767a291ef4fc1d3c5dcf7cae8c94d99b1144a582c988b8e5426d98

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
