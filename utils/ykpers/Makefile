include $(TOPDIR)/rules.mk

PKG_NAME:=ykpers
PKG_VERSION:=1.19.0
PKG_RELEASE:=1

PKG_SOURCE:=ykpers-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://developers.yubico.com/yubikey-personalization/Releases
PKG_HASH:=2bc8afa16d495a486582bad916d16de1f67c0cce9bb0a35c3123376c2d609480
PKG_MAINTAINER:=Stuart B. Wilkins <stuwilkins@mac.com>
PKG_LICENSE_FILES:=COPYING
PKG_LICENSE:=BSD-2-Clause

PKG_BUILD_DIR:=$(BUILD_DIR)/ykpers-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=libyubikey

include $(INCLUDE_DIR)/package.mk

define Package/ykpers
  SECTION:=utils	
  CATEGORY:=Utilities
  TITLE:=The Yuibco personalization package
  URL:=https://developers.yubico.com/yubikey-personalization/
  DEPENDS:=+curl +libyubikey +libjson-c +libusb-1.0
endef

define Package/ykpers/description
	The YubiKey Personalization package contains a library and command 
	line tool used to personalize (i.e., set a AES key) YubiKeys.
endef

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-static


define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include
	$(CP) $(PKG_BUILD_DIR)/ykcore/*.h $(STAGING_DIR)/usr/include
	$(CP) $(PKG_BUILD_DIR)/*.h $(STAGING_DIR)/usr/include
	$(INSTALL_DIR) $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/libykpers-1.so* $(STAGING_DIR)/usr/lib
endef

define Package/ykpers/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/ykchalresp $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/ykinfo $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/ykpersonalize $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/libykpers-1.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,ykpers))
