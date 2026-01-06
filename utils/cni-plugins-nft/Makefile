include $(TOPDIR)/rules.mk

PKG_NAME:=cni-plugins-nft
PKG_VERSION:=1.0.12
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/greenpau/cni-plugins
PKG_MIRROR_HASH:=3bb778c8f48261eaaee8b14b9219f1730967ef16158b5b540d45da54ef580e53

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/greenpau/cni-plugins/
GO_PKG_BUILD_PKG:=github.com/greenpau/cni-plugins/cmd/cni-nftables-portmap \
		github.com/greenpau/cni-plugins/cmd/cni-nftables-firewall

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/cni-plugins-nft
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=CNI Plugins compatible with nftables
  URL:=https://github.com/greenpau/cni-plugins/
  DEPENDS:=$(GO_ARCH_DEPENDS) +nftables
endef

define Package/cni-plugins-nft/description
  CNI Plugins maintained by the CNI team do not support nftables, except when used with systemd.
  These plugins do.
    - cni-nftables-portmap
    - cni-nftables-firewall
endef

define Package/cni-plugins-nft/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/lib/cni
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/lib/cni
endef

$(eval $(call GoBinPackage,cni-plugins-nft))
$(eval $(call BuildPackage,cni-plugins-nft))
