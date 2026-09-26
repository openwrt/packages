include $(TOPDIR)/rules.mk

PKG_NAME:=ledmatrixd
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Benoit Masson <benoitm974@users.noreply.github.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/ledmatrixd
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Userspace LED matrix controller
  DEPENDS:=@TARGET_qualcommbe +libuci +kmod-i2c-core
endef

define Package/ledmatrixd/description
  Controls the TP-Link Archer BE800 front-panel LED matrix through its
  three IS31FL3737-compatible I2C controllers.
endef

define Package/ledmatrixd/conffiles
/etc/config/ledmatrix
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CPPFLAGS) $(TARGET_CFLAGS) -Wall -Wextra \
		-DVERSION=\"$(PKG_VERSION)\" -o $(PKG_BUILD_DIR)/ledmatrixd \
		$(PKG_BUILD_DIR)/ledmatrixd.c $(TARGET_LDFLAGS) -luci
	$(TARGET_CC) $(TARGET_CPPFLAGS) $(TARGET_CFLAGS) -Wall -Wextra \
		-DVERSION=\"$(PKG_VERSION)\" -o $(PKG_BUILD_DIR)/ledmatrixctl \
		$(PKG_BUILD_DIR)/ledmatrixctl.c \
		$(TARGET_LDFLAGS)
endef

define Package/ledmatrixd/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/share/ledmatrixd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ledmatrixd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ledmatrixctl $(1)/usr/sbin/
	$(INSTALL_DATA) ./files/regmap.bin $(1)/usr/share/ledmatrixd/
	$(INSTALL_DATA) ./files/layout.bin $(1)/usr/share/ledmatrixd/
	$(INSTALL_DATA) ./files/openwrt.bin $(1)/usr/share/ledmatrixd/
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) ./files/ledmatrix.config $(1)/etc/config/ledmatrix
	$(INSTALL_BIN) ./files/ledmatrix.init $(1)/etc/init.d/ledmatrixd
endef

define Package/ledmatrixd/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || /etc/init.d/ledmatrixd enable
endef

$(eval $(call BuildPackage,ledmatrixd))
