include $(TOPDIR)/rules.mk

PKG_NAME:=https-dns-proxy
PKG_VERSION:=2025.03.13
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/aarond10/https_dns_proxy/
PKG_SOURCE_VERSION:=0e074b40f3e20d7564faa81d1c21602dcf534313
PKG_MIRROR_HASH:=85c32f80ebe49c152a8ad75fa0c970026523fee445c9344d75e109b6736c59e5

PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

TARGET_CFLAGS += $(FPIC)
TARGET_LDFLAGS += -Wl,--gc-sections
CMAKE_OPTIONS += -DCLANG_TIDY_EXE= -DSW_VERSION=$(PKG_VERSION)-r$(PKG_RELEASE)

CONFIGURE_ARGS += \
	$(if $(CONFIG_LIBCURL_OPENSSL),--with-openssl="$(STAGING_DIR)/usr",--without-openssl) \
	$(if $(CONFIG_LIBCURL_NGHTTP2),--with-nghttp2="$(STAGING_DIR)/usr",--without-nghttp2) \
	$(if $(CONFIG_LIBCURL_NGHTTP3),--with-nghttp3="$(STAGING_DIR)/usr",--without-nghttp3) \
	$(if $(CONFIG_LIBCURL_NGTCP2),--with-ngtcp2="$(STAGING_DIR)/usr",--without-ngtcp2) \

define Package/https-dns-proxy
	SECTION:=net
	CATEGORY:=Network
	TITLE:=DNS Over HTTPS Proxy
	URL:=https://github.com/stangri/https-dns-proxy/
	DEPENDS:=+libcares +libcurl +libev +ca-bundle +jsonfilter +resolveip
	DEPENDS+=+!BUSYBOX_DEFAULT_GREP:grep
	DEPENDS+=+!BUSYBOX_DEFAULT_SED:sed
	CONFLICTS:=https_dns_proxy
endef

define Package/https-dns-proxy/description
Light-weight DNS-over-HTTPS, non-caching translation proxy for the RFC 8484 DoH standard.
It receives regular, unencrypted (UDP) DNS requests and resolves them via DoH resolver.
Please see https://docs.openwrt.melmac.net/https-dns-proxy/ for more information.
endef

define Package/https-dns-proxy/conffiles
/etc/config/https-dns-proxy
endef

define Package/https-dns-proxy/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/https_dns_proxy $(1)/usr/sbin/https-dns-proxy
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/https-dns-proxy $(1)/etc/init.d/https-dns-proxy
	$(SED) "s|^\(readonly PKG_VERSION\).*|\1='$(PKG_VERSION)-r$(PKG_RELEASE)'|" $(1)/etc/init.d/https-dns-proxy
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/https-dns-proxy $(1)/etc/config/https-dns-proxy
	$(INSTALL_DIR) $(1)/etc/uci-defaults/
	$(INSTALL_BIN) ./files/etc/uci-defaults/50-https-dns-proxy-migrate-options.sh $(1)/etc/uci-defaults/50-https-dns-proxy-migrate-options.sh
endef

$(eval $(call BuildPackage,https-dns-proxy))
