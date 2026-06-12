include $(TOPDIR)/rules.mk

PKG_NAME:=ua3f
PKG_VERSION:=3.6.0
PKG_RELEASE:=1

PKG_SOURCE:=UA3F-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/SunBK201/UA3F/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=067664cf78e2bdb7855e474903da1755d28bee511b5e70b5751d6dc677788bd5
PKG_BUILD_DIR:=$(BUILD_DIR)/UA3F-$(PKG_VERSION)

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=SunBK201 <sunbk201gm@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/sunbk201/ua3f
GO_PKG_LDFLAGS_X:=main.appVersion=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/ua3f
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=Advanced HTTP Rewriting Proxy
	URL:=https://github.com/SunBK201/UA3F
	DEPENDS:=$(GO_ARCH_DEPENDS) +nftables +kmod-nft-queue +kmod-nft-tproxy +kmod-nf-conntrack-netlink
endef

define Package/ua3f/description
	UA3F is an HTTP rewriting tool that transparently rewrites HTTP (e.g., User-Agent) as an HTTP, SOCKS5, TPROXY, REDIRECT, or NFQUEUE server.
endef

define Package/ua3f/conffiles
/etc/config/ua3f
endef

define Package/ua3f/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/ua3f $(1)/usr/bin/ua3f

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ua3f.conf $(1)/etc/config/ua3f

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ua3f.init $(1)/etc/init.d/ua3f
endef

$(eval $(call GoBinPackage,ua3f))
$(eval $(call BuildPackage,ua3f))
