include $(TOPDIR)/rules.mk


PKG_NAME:=xs2184-tsw202
PKG_VERSION:=1.0.2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_MAINTAINER:=patrick <patrick@lunatiki.de>
PKG_SOURCE_VERSION:=4.4
PKG_SOURCE_NAME:=i2c-tools
PKG_SOURCE_URL:=@KERNEL/software/utils/i2c-tools
PKG_HASH:=8b15f0a880ab87280c40cfd7235cfff28134bf14d5646c07518b1ff6642a2473
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_SOURCE_VERSION).tar.xz

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_BIG_ENDIAN),y)
TARGET_CFLAGS+= -DHAVE_BIG_ENDIAN=1
endif
TARGET_CFLAGS+= -D_GNU_SOURCE

define Package/xs2184-tsw202
  SECTION:=Applications
  CATEGORY:=Network
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=XinSheng PoE/PSE i2c driver for Teltonika TSW202 Switch
  DEPENDS:=+i2c-tools +libuci
endef

define Package/xs2184-tsw202/description
  ZheJiang XinSheng PoE/PSE SoC devices drivers;
endef

define Build/Prepare
	$(Build/Prepare/Default)
	$(CP) $(BUILD_DIR)/i2c-tools-$(PKG_SOURCE_VERSION)/tools/i2cbusses.c $(PKG_BUILD_DIR)/libxs2184
	$(CP) $(BUILD_DIR)/i2c-tools-$(PKG_SOURCE_VERSION)/tools/i2cbusses.h $(PKG_BUILD_DIR)/libxs2184
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		TARGET=Linux \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/xs2184-tsw202/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/xs2184 $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/xs2184.init $(1)/etc/init.d/xs2184
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/xs2184.config $(1)/etc/config/xs2184
endef

$(eval $(call BuildPackage,xs2184-tsw202))
