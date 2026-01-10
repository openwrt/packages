include $(TOPDIR)/rules.mk


PKG_NAME:=xs2184-tsw202
PKG_VERSION:=1.0.2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_MAINTAINER:=patrick <patrick@lunatiki.de>

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
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/files \
		$(TARGET_CONFIGURE_OPTS) \
		TARGET=Linux \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/xs2184-tsw202/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/xs2184 $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/xs2184.init $(1)/etc/init.d/xs2184
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/xs2184.config $(1)/etc/config/xs2184
endef

$(eval $(call BuildPackage,xs2184-tsw202))
