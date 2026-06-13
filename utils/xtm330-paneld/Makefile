include $(TOPDIR)/rules.mk

PKG_NAME:=xtm330-paneld
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/xtm330-paneld
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=WatchGuard XTM330 front panel daemon
endef

define Package/xtm330-paneld/description
 Small userspace daemon for the WatchGuard XTM330 front panel.
 It initializes the LCD/keypad controller on ttyS1, writes status
 text to the display, and logs keypad events.
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -o $(PKG_BUILD_DIR)/xtm330-paneld ./src/xtm330-paneld.c
endef

define Package/xtm330-paneld/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/xtm330-paneld $(1)/usr/sbin/xtm330-paneld
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/xtm330-paneld.init $(1)/etc/init.d/xtm330-paneld
endef

$(eval $(call BuildPackage,xtm330-paneld))
