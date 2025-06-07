include $(TOPDIR)/rules.mk

PKG_NAME:=ratelimit
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Thibaut VARÈNE <hacks@slashdirt.org>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/f00b4r0/ratelimit.git
PKG_SOURCE_DATE:=2025-06-14
PKG_SOURCE_VERSION:=60405a069668d30b2060cc9b4fdbfcd93c720658
PKG_MIRROR_HASH:=324cb1b55acfe0b140e098f299a05c76b2d8382b2f4a6836343abe24e4c0889c

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
