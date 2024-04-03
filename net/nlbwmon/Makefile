include $(TOPDIR)/rules.mk

PKG_NAME:=nlbwmon
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jow-/nlbwmon.git
PKG_SOURCE_DATE:=2024-02-21
PKG_SOURCE_VERSION:=c7616bcfaaef440848152f4dc738c990b2d0b90b
PKG_MIRROR_HASH:=3cbcd2e180547719b48c58d88f30d1296fd2db62a6a6aa96a13b485e58022903

CMAKE_INSTALL:=1

PKG_MAINTAINER:=Jo-Philipp Wich <jo@mein.io>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DLIBNL_LIBRARY_TINY=ON
TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/libnl-tiny

define Package/nlbwmon
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libubox +libnl-tiny +zlib +kmod-nf-conntrack-netlink
  TITLE:=OpenWrt Traffic Usage Monitor
endef

define Package/nlbwmon/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/nlbwmon $(1)/usr/sbin/nlbwmon
	$(LN) nlbwmon $(1)/usr/sbin/nlbw
	$(INSTALL_DIR) $(1)/usr/share/nlbwmon
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/protocols.txt $(1)/usr/share/nlbwmon/protocols
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nlbwmon.init $(1)/etc/init.d/nlbwmon
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/nlbwmon.config $(1)/etc/config/nlbwmon
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/nlbwmon.hotplug $(1)/etc/hotplug.d/iface/30-nlbwmon
endef

define Package/nlbwmon/conffiles
/etc/config/nlbwmon
/usr/share/nlbwmon/protocols
endef


$(eval $(call BuildPackage,nlbwmon))
