include $(TOPDIR)/rules.mk

PKG_NAME:=antiblock
PKG_VERSION:=2.1.2
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/karen07/antiblock
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=18b04ab99744160e91d032edc55bb171a9717cdd200a494d7af9fa3c9f0fdb48

PKG_MAINTAINER:=Khachatryan Karen <karen0734@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/antiblock
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libcurl +libpcap
  TITLE:=AntiBlock
  URL:=https://github.com/karen07/antiblock
endef

define Package/antiblock/description
  AntiBlock sniffer DNS requests. The IP addresses of the
  specified domains are added to the routing table for
  routing through the specified interfaces.
endef

define Package/antiblock/conffiles
/etc/config/antiblock
endef

define Package/antiblock/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/antiblock $(1)/usr/bin/antiblock

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/antiblock $(1)/etc/init.d/antiblock

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/antiblock $(1)/etc/config/antiblock
endef

$(eval $(call BuildPackage,antiblock))
