include $(TOPDIR)/rules.mk

PKG_NAME:=udhcpsnoop
PKG_RELEASE:=2

PKG_LICENSE:=BSD-3-Clause
PKG_MAINTAINER:=John Crispin <john@phrozen.org>

PKG_SOURCE_URL=https://github.com/blogic/udhcpsnoop.git
PKG_MIRROR_HASH:=7ec9fb542a56d48740bf98d6bb6283704fd0cab1b35a1accb0beb587e45c39ab
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2021-05-30
PKG_SOURCE_VERSION:=b86639904147a40be32ac43cd89c21109ffc3543

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/udhcpsnoop
  SECTION:=net
  CATEGORY:=Network
  TITLE:=DHCP Snooping Daemon
  DEPENDS:=+libubox +libubus +libuci
endef

define Package/udhcpsnoop/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/udhcpsnoop $(1)/usr/sbin/
	$(CP) ./files/* $(1)
endef

define Package/udhcpsnoop/conffiles
/etc/config/dhcpsnoop
endef

$(eval $(call BuildPackage,udhcpsnoop))
