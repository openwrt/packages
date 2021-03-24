include $(TOPDIR)/rules.mk

PKG_NAME:=https-dns-proxy
PKG_VERSION:=2021-02-26
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/aarond10/https_dns_proxy
PKG_SOURCE_DATE:=2021-02-26
PKG_SOURCE_VERSION:=33c6a0dda433c3bcf911b5323b6e9c9bae8cf78e
PKG_MIRROR_HASH:=c47e796f6b1cbcdfdc45722c4f45f32ba0535bb714c03ed7591bf42694772a12

PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../../devel/ninja/ninja-cmake.mk

CMAKE_OPTIONS += -DCLANG_TIDY_EXE=

define Package/https-dns-proxy
	SECTION:=net
	CATEGORY:=Network
	TITLE:=DNS Over HTTPS Proxy
	URL:=https://docs.openwrt.melmac.net/https-dns-proxy/
	DEPENDS:=+libcares +libcurl +libev +ca-bundle
	CONFLICTS:=https_dns_proxy
endef

define Package/https-dns-proxy/description
https-dns-proxy is a light-weight DNS<-->HTTPS, non-caching translation proxy for the RFC 8484 DoH standard.
It receives regular (UDP) DNS requests and issues them via DoH.
Please see https://docs.openwrt.melmac.net/https-dns-proxy/ for more information.
endef

define Package/https-dns-proxy/conffiles
/etc/config/https-dns-proxy
endef

define Package/https-dns-proxy/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d ${1}/etc/config
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/https_dns_proxy $(1)/usr/sbin/https-dns-proxy
	$(INSTALL_BIN) ./files/https-dns-proxy.init $(1)/etc/init.d/https-dns-proxy
	$(SED) "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/https-dns-proxy
	$(INSTALL_CONF) ./files/https-dns-proxy.config $(1)/etc/config/https-dns-proxy
endef

$(eval $(call BuildPackage,https-dns-proxy))
