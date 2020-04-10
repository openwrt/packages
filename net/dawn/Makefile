#
# This software is licensed under the Public Domain.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dawn
PKG_SOURCE_DATE:=2020-04-10
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/berlin-open-wireless-lab/DAWN.git
PKG_SOURCE_VERSION:=5709b96a4dc156ffc8e846360c6d3ecc6584605b
PKG_MIRROR_HASH:=c1d080eb8ae1d9ee07ebcf91e0a1e7c731875b142ebf838a75043c197fec4c37

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

define Package/dawn/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/dawn $(1)/usr/sbin/dawn
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dawn.init $(1)/etc/init.d/dawn
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/dawn.config $(1)/etc/config/dawn
endef

$(eval $(call BuildPackage,dawn))
