include $(TOPDIR)/rules.mk

PKG_NAME:=ratelimit
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/f00b4r0/ratelimit.git
PKG_SOURCE_DATE:=2025-06-07
PKG_SOURCE_VERSION:=4ef5917170b544fffcb1f3be92c73331321c7f0c
PKG_MIRROR_HASH:=95292fa86e2652c5a7665c14ae83806ca8ef9ad3ee1826f5b20663ae8987d59a

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Thibaut VARÈNE <hacks@slashdirt.org>

include $(INCLUDE_DIR)/package.mk

define Package/ratelimit
  SECTION:=net
  CATEGORY:=Network
  TITLE:=client devices ratelimiting daemon
  DEPENDS:=+tc +kmod-ifb +ucode-mod-log
  PKGARCH:=all
endef

define Package/ratelimit/description
  This daemon provides a stateful interface to the HTB traffic shaper,
  enabling per-client bandwidth limits assignment.
endef

define Package/ratelimit/conffiles
/etc/config/ratelimit
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/ratelimit/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/hotplug.d/iface $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/etc/hotplug.d/iface/50-ratelimit $(1)/etc/hotplug.d/iface/50-ratelimit
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/files/etc/config/ratelimit $(1)/etc/config/ratelimit
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/init.d/ratelimit $(1)/etc/init.d/ratelimit
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/usr/sbin/ratelimit $(1)/usr/sbin/ratelimit
endef

$(eval $(call BuildPackage,ratelimit))
