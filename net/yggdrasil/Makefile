include $(TOPDIR)/rules.mk

PKG_NAME:=yggdrasil
PKG_VERSION:=0.5.13
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/yggdrasil-network/yggdrasil-go/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=e19a3c3121d6a5e9abdc9f4d42decbd62ed97ccbe301c842f2d30ac1eba9c4c2
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-go-$(PKG_VERSION)

PKG_MAINTAINER:=William Fleurant <meshnet@protonmail.com>
PKG_LICENSE:=LGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/yggdrasil-network/yggdrasil-go
GO_PKG_BUILD_PKG:=github.com/yggdrasil-network/yggdrasil-go/cmd/...

GO_PKG_LDFLAGS_X:= \
  github.com/yggdrasil-network/yggdrasil-go/src/version.buildName=yggdrasil-openwrt \
  github.com/yggdrasil-network/yggdrasil-go/src/version.buildVersion=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/yggdrasil
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Routing and Redirection
	TITLE:=Yggdrasil supports end-to-end encrypted IPv6 networks
	URL:=https://yggdrasil-network.github.io/
	DEPENDS:=$(GO_ARCH_DEPENDS) @IPV6 +kmod-tun
endef

define Package/yggdrasil/description
 Yggdrasil builds end-to-end encrypted networks with IPv6.
endef

define Package/yggdrasil/install
	$(INSTALL_DIR) \
		$(1)/lib/netifd/proto \
		$(1)/usr/sbin

	$(INSTALL_BIN) \
		$(GO_PKG_BUILD_BIN_DIR)/yggdrasil \
		$(1)/usr/sbin

	$(INSTALL_BIN) \
		$(GO_PKG_BUILD_BIN_DIR)/yggdrasilctl \
		$(1)/usr/sbin

	$(INSTALL_BIN) \
		./files/yggdrasil.sh \
		$(1)/lib/netifd/proto
endef

$(eval $(call GoBinPackage,yggdrasil))
$(eval $(call BuildPackage,yggdrasil))
