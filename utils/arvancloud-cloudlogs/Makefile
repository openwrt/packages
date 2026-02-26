# Copyright (c) Mohammad Abbasi <mohammad.v184@gmail.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=arvancloud-cloudlogs
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Mohammad Abbasi <mohammad.v184@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE


PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mohammadv184/openwrt-arvancloud-cloudlogs
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_DATE:=2025-11-07
PKG_MIRROR_HASH:=233208bb96f0d98e0e213b6beae025974413debe66b73f71b3f44e3f9cd5f203

include $(INCLUDE_DIR)/package.mk

define Package/arvancloud-cloudlogs
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Forward OpenWrt logd entries to ArvanCloud CloudLogs
  URL:=https://github.com/mohammadv184/openwrt-arvancloud-cloudlogs
  DEPENDS:=+libubus +libubox +libcurl
endef

define Package/arvancloud-cloudlogs/description
 A small daemon that subscribes to logd via ubus and forwards logs to ArvanCloud CloudLogs service.
endef


TARGET_CFLAGS += -Wall -Wextra -O2

TARGET_LDFLAGS += -lubus -lubox -lcurl

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/arvancloud-cloudlogs/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/arvancloud-cloudlogs $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/arvancloud-cloudlogs.init $(1)/etc/init.d/arvancloud-cloudlogs
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/arvancloud-cloudlogs.conf $(1)/etc/config/arvancloud-cloudlogs
endef

define Package/arvancloud-cloudlogs/conffiles
/etc/config/arvancloud-cloudlogs
endef

$(eval $(call BuildPackage,arvancloud-cloudlogs))
