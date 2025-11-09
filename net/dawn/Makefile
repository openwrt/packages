#
# This software is licensed under the Public Domain.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dawn
PKG_SOURCE_DATE:=2025-11-07
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/berlin-open-wireless-lab/DAWN.git
PKG_SOURCE_VERSION:=7414c34a08c7cbbd5f292e0e25e53f1edbfc751a
PKG_MIRROR_HASH:=9663f6e75e9bf8cb2c38df6348ee6163c472d3c0cd1c10eedeab60ddb824dc0e

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_FLAGS:=no-lto

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/dawn
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Wireless
  TITLE:=Decentralized wifi controller
  URL:=https://github.com/berlin-open-wireless-lab/DAWN.git
  DEPENDS:=$(DRV_DEPENDS) +libubus +libubox +libblobmsg-json +libuci +libgcrypt +libiwinfo +umdns
endef

define Package/dawn/description
  This package implements a decentralized wireless daemon.
endef

define Package/dawn/conffiles
/etc/config/dawn
endef

define Package/dawn/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/dawn $(1)/usr/sbin/dawn
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dawn.init $(1)/etc/init.d/dawn
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/dawn.config $(1)/etc/config/dawn
endef

$(eval $(call BuildPackage,dawn))
