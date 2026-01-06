include $(TOPDIR)/rules.mk

PKG_NAME:=cni-plugins
PKG_VERSION:=1.1.1
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/containernetworking/plugins
PKG_MIRROR_HASH:=4372700fa1fb159235586432800f228d92246d13571f5a29aa9bc58291eac6d9

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>, Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/containernetworking/plugins/
GO_PKG_BUILD_PKG:=github.com/containernetworking/plugins/plugins/main/... \
		  github.com/containernetworking/plugins/plugins/meta/... \
		  github.com/containernetworking/plugins/plugins/ipam/...

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/cni-plugins
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=cni-plugins
  URL:=https://github.com/containernetworking/cni-plugins
  DEPENDS:=$(GO_ARCH_DEPENDS) +ip-full +kmod-veth
endef

define Package/cni-plugins/description
  Some CNI network plugins, maintained by the containernetworking team. For
  more information, see the individual READMEs.
endef

define Package/cni-plugins/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/lib/cni
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/lib/cni
endef

$(eval $(call GoBinPackage,cni-plugins))
$(eval $(call BuildPackage,cni-plugins))
