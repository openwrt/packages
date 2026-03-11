include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-go
PKG_VERSION:=6.16.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jeessy2/ddns-go/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=eb2f8f924e649c71057ef5745ee8f52d27ef72064a2391bf5b90ef51a8ee0293

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=sirpdboy  <herboy2008@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/jeessy2/ddns-go/v6
GO_PKG_LDFLAGS_X:=main.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/ddns-go
  TITLE:=Support IPV4 and IPV6 simple and easy-to-use IP binding domain name tool
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  URL:=https://github.com/jeessy2/ddns-go
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
  USERID:=ddns-go:ddns-go
endef

define Package/ddns-go/description
  A simple and easy-to-use IP binding domain name tool that supports IPV4 and IPV6,
  support Alidns Dnspod Cloudflare Hicloud Callback Baiducloud porkbun GoDaddy Google Domains.
endef

define Package/ddns-go/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/ddns-go.init $(1)/etc/init.d/ddns-go
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/ddns-go.conf $(1)/etc/config/ddns-go
endef

define Package/ddns-go/conffiles
/etc/config/ddns-go
/etc/ddns-go/ddns-go-config.yaml
endef

$(eval $(call GoBinPackage,ddns-go))
$(eval $(call BuildPackage,ddns-go))
