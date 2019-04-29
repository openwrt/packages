include $(TOPDIR)/rules.mk

PKG_NAME:=beardropper
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Ansuel/bearDropper
PKG_MIRROR_HASH:=9d1dff6762d61a8a1f26c32d7933248a613c2597de7006d3bdae7e18a86e1d20
PKG_SOURCE_DATE:=28-04-2019
PKG_SOURCE_VERSION:=d68896279c8dccf17a15d0bf9fc1fd35690e8192

PKG_MAINTAINER:=Ansuel Smith <ansuelsmth@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/beardropper
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+busybox
  TITLE:=Dropbear log parsing Ban Agent
  URL:=https://github.com/Ansuel/bearDropper
  PKGARCH:=all
endef

define Package/beardropper/description
	dropbear log parsing ban agent for OpenWRT (Chaos Calmer rewrite of dropBrute.sh) - @robzr
	OpenWRT (Chaos Calmer) script for blocking repeated invalid dropbear ssh connection attempts (embedded fail2ban)
endef

define Package/beardropper/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/init.d/beardropper  $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/config/beardropper  $(1)/etc/config/
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/beardropper  $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/80_check-dropbear-verbose $(1)/etc/uci-defaults/80_check-dropbear-verbose
endef

$(eval $(call BuildPackage,beardropper))
