include $(TOPDIR)/rules.mk

PKG_NAME:=cni-plugins-nft
PKG_VERSION:=1.0.11
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/greenpau/cni-plugins/archive/v$(PKG_VERSION)
PKG_HASH:=f6c68268893c9d9967dd4d8f3684df0f4f989e7ebf373e72b20d1f290ff9e240

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/greenpau/cni-plugins/
GO_PKG_BUILD_PKG:=github.com/greenpau/cni-plugins/cmd/cni-nftables-portmap \
		github.com/greenpau/cni-plugins/cmd/cni-nftables-firewall

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

PKG_UNPACK:=$(HOST_TAR) -C "$(PKG_BUILD_DIR)" --strip-components=1 -xzf "$(DL_DIR)/$(PKG_SOURCE)"

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
