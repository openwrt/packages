include $(TOPDIR)/rules.mk

PKG_NAME:=radius-mac
# Generally, our PKG_VERSION should match our PKG_SOURCE_VERSION
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/carlanton/radius-mac.git
PKG_SOURCE_VERSION:=release-0.1

PKG_MAINTAINER:=Brian 'redbeard' Harrington <redbeard@dead-city.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/radius-mac
	SECTION:=net
	CATEGORY:=Network
	TITLE:=RADIUS server providing MAC addresss authentication
	URL:=https://github.com/carlanton/radius-mac
	DEPENDS:=+libuci
endef

define Package/radius-mac/description
	A simple RADIUS server for MAC address authentication.
endef

define Package/radius-mac/conffiles
/etc/config/radius-mac
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/src \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/radius-mac/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/radius-mac $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/radius-mac.conf $(1)/etc/config/radius-mac

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/radius-mac.init $(1)/etc/init.d/radius-mac

	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/radius-mac.upgrade $(1)/lib/upgrade/keep.d/radius-mac
endef

$(eval $(call BuildPackage,radius-mac))
