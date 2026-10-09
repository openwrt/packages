include $(TOPDIR)/rules.mk

PKG_NAME:=antiblock
PKG_VERSION:=3.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/karen07/antiblock
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=39366b6399f84e28721e66f25864fa920349d42ef9243823355c565468e59dda

PKG_MAINTAINER:=Karen Khachatryan <karen0734@gmail.com>
PKG_LICENSE:=AGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/antiblock
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libcurl +libpcap
  TITLE:=DNS-based dynamic IPv4 routing
  URL:=https://github.com/karen07/antiblock
endef

define Package/antiblock/description
  AntiBlock monitors DNS responses for configured domains and
  dynamically installs IPv4 host routes through selected network
  interfaces. Supports both L3 interfaces and L2 interfaces
  with default gateways.
endef

define Package/antiblock/conffiles
/etc/config/antiblock
endef

define Package/antiblock/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/antiblock $(1)/usr/bin/antiblock

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/etc/init.d/antiblock $(1)/etc/init.d/antiblock

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/etc/config/antiblock $(1)/etc/config/antiblock
endef

$(eval $(call BuildPackage,antiblock))
