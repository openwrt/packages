include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-go
PKG_VERSION:=6.15.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jeessy2/ddns-go/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=f4443c44c7247fee49bfbd8e06b7c03b2f59cb99968e685b5655017cbd8dabf8

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=sirpdboy  <herboy2008@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/jeessy2/ddns-go/v6
GO_PKG_LDFLAGS_X:=main.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/ddns-go
  TITLE:=A Linux web GUI client of ddns-go
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=https://github.com/jeessy2/ddns-go
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
  USERID:=ddns-go:ddns-go
endef

define Package/ddns-go/description
  ddns-go is a automatically obtain your public IPv4 or IPv6 address and resolve it to the corresponding domain name service,
  support Alidns Dnspod Cloudflare Hicloud Callback Baiducloud porkbun GoDaddy Google Domains.
endef

define Package/ddns-go/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/ddns-go.init $(1)/etc/init.d/ddns-go
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(CURDIR)/files/ddns-go-call.libexec $(1)/usr/libexec/ddns-go-call
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/ddns-go.conf $(1)/etc/config/ddns-go
endef

define Package/ddns-go/conffiles
/etc/config/ddns-go
/etc/ddns-go/ddns-go-config.yaml
endef

$(eval $(call GoBinPackage,ddns-go))
$(eval $(call BuildPackage,ddns-go))
