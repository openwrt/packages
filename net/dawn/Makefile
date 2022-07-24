#
# This software is licensed under the Public Domain.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dawn
PKG_SOURCE_DATE:=2022-07-24
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/berlin-open-wireless-lab/DAWN.git
PKG_SOURCE_VERSION:=9e8060ea0908a1092cb07efead1226f494884a71
PKG_MIRROR_HASH:=305538c6a03d4680c709af7801436a7bae2a811ea4f2f1bd41e42e56e71f2cc7

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/dawn
  SECTION:=net
  CATEGORY:=Network
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
