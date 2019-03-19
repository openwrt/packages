include $(TOPDIR)/rules.mk

PKG_NAME:=yggdrasil
PKG_VERSION:=0.3.5
PKG_RELEASE:=2

PKG_SOURCE_URL:=https://codeload.github.com/yggdrasil-network/yggdrasil-go/tar.gz/v$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=2c69029adeb053ad049e90f1e4b7efa986094779868da77464d3c869984e861b
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-go-$(PKG_VERSION)

PKG_LICENSE:=GPL-3.0
PKG_MAINTAINER:=William Fleurant <meshnet@protonmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/yggdrasil
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Routing and Redirection
	TITLE:=Yggdrasil supports end-to-end encrypted IPv6 networks
	URL:=https://yggdrasil-network.github.io/
	DEPENDS:=$(GO_ARCH_DEPENDS) @IPV6 +kmod-tun +@(mips):KERNEL_MIPS_FPU_EMULATOR
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

ifeq ($(ARCH),aarch64)
	GOARCH:=arm64
endif

ifeq ($(ARCH),arc)
	GOARCH:=risc
endif

ifeq ($(ARCH),arc)
	GOARCH:=risc
endif

ifeq ($(ARCH),arm)
	GOARCH:=arm
endif

ifeq ($(ARCH),armeb)
	GOARCH:=armbe
endif

ifeq ($(ARCH),i386)
	GOARCH:=386
endif

ifeq ($(ARCH),mips)
	GOARCH:=mips
endif

ifeq ($(ARCH),mips64)
	GOARCH:=mips64
endif

ifeq ($(ARCH),mipsel)
	GOARCH:=mipsle
endif

ifeq ($(ARCH),powerpc)
	GOARCH:=ppc64
endif

define Build/Compile
	cd $(PKG_BUILD_DIR) && \
	GOOS="linux" \
	GOARCH="$(GOARCH)" \
	PKGVER="$(PKG_VERSION)" \
	PKGNAME="yggdrasil-openwrt" \
	$(PKG_BUILD_DIR)/build
endef

define Package/yggdrasil/install
	$(INSTALL_DIR) \
		$(1)/etc/init.d \
		$(1)/etc/uci-defaults \
		$(1)/usr/sbin

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/yggdrasil \
		$(1)/usr/sbin

	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/yggdrasilctl \
		$(1)/usr/sbin

	$(INSTALL_BIN) \
		./files/yggdrasil.defaults \
		$(1)/etc/uci-defaults/yggdrasil

	$(INSTALL_BIN) \
		./files/yggdrasil.init \
		$(1)/etc/init.d/yggdrasil
endef

$(eval $(call BuildPackage,yggdrasil))
