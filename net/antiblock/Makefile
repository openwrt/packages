include $(TOPDIR)/rules.mk

PKG_NAME:=antiblock
PKG_VERSION:=2.0.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/karen07/antiblock
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=bfde3c4f5f3ca4f4c8ad679b4d3f367fef3021e6aae61ce2d5f283e6775db8bb

PKG_MAINTAINER:=Khachatryan Karen <karen0734@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/antiblock
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libcurl
  TITLE:=AntiBlock
  URL:=https://github.com/karen07/antiblock
endef

define Package/antiblock/description
  AntiBlock program proxies DNS requests.
  The IP addresses of the specified domains are added to
  the routing table for routing through the specified interface.
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
