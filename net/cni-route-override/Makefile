include $(TOPDIR)/rules.mk

PKG_NAME:=cni-route-override
PKG_VERSION:=0.1
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/redhat-nfvpe/$(PKG_NAME).git
PKG_SOURCE_DATE:=2021-11-29
PKG_SOURCE_VERSION:=6263d6876c6aa52d6b660e4b54da6b0b58b04022
PKG_MIRROR_HASH:=4e72031285a00ef0d3c70373e2791397b12649f21e9511ce761fa7404f35d71c

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/redhat-nfvpe/$(PKG_NAME)/
GO_PKG_BUILD_PKG:=github.com/redhat-nfvpe/$(PKG_NAME)/cmd/route-override

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/cni-route-override
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Meta CNI plugin for overriding IP route
  URL:=https://github.com/redhat-nfvpe/cni-route-override/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/cni-route-override/description
  route-override IPAM works as meta CNI plugin to override IP route given by previous CNI plugins.
endef

define Package/cni-route-override/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/lib/cni
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/lib/cni
endef

$(eval $(call GoBinPackage,cni-route-override))
$(eval $(call BuildPackage,cni-route-override))
