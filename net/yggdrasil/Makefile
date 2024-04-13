include $(TOPDIR)/rules.mk

PKG_NAME:=yggdrasil
PKG_VERSION:=0.5.5
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/yggdrasil-network/yggdrasil-go/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=cdbb56b19b91b828afa282554862efb2a79dd4ada26dfb5a7bf3b0c5220f6c17
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
 Beyond the similarities with cjdns is a different routing
 algorithm. This globally-agreed spanning tree uses greedy
 routing in a metric space. Back-pressure routing techniques
 allow advanced link aggregation bonding on per-stream basis.
 In turn, a single stream will span across multiple network
 interfaces simultaneously with much greater throughput.
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
