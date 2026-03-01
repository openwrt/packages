include $(TOPDIR)/rules.mk

PKG_NAME:=mini-mwan
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Alex Schwartzman <openwrt@schwartzman.uk>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/mini-mwan
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Mini Multi-WAN daemon
  DEPENDS:= \
    +libubox-lua \
    +libubus-lua \
    +libuci-lua \
    +lua \
    +lua-cjson \
    +luci-lib-nixio
  PKGARCH:=all
endef

define Package/mini-mwan/description
  Lightweight multi-WAN management daemon with failover and load balancing.
  Monitors WAN interface connectivity and manages routing based on interface status.
  Can be configured via UCI or LuCI (install luci-app-mini-mwan for web interface).
endef

define Build/Compile
endef

define Package/mini-mwan/conffiles
/etc/config/mini-mwan
endef

define Package/mini-mwan/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/mini-mwan.lua $(1)/usr/bin/mini-mwan

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/mini-mwan.config $(1)/etc/config/mini-mwan

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mini-mwan.init $(1)/etc/init.d/mini-mwan
endef

$(eval $(call BuildPackage,mini-mwan))
