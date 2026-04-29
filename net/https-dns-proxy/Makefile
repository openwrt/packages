# SPDX-License-Identifier: MIT
include $(TOPDIR)/rules.mk

PKG_NAME:=https-dns-proxy
PKG_VERSION:=2026.03.18
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/aarond10/https_dns_proxy/
PKG_MIRROR_HASH:=4c356c19b62fc7bdef3a67fd678e48f3659d709da10517c2eadef76e3409f5ce
PKG_SOURCE_VERSION:=801881210ba8215dc9cd577222d8c10372423360

PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

TARGET_CFLAGS += $(FPIC)
TARGET_LDFLAGS += -Wl,--gc-sections
CMAKE_OPTIONS += -DCLANG_TIDY_EXE= -DSW_VERSION=$(PKG_VERSION)-r$(PKG_RELEASE)

define Package/https-dns-proxy
	SECTION:=net
	CATEGORY:=Network
	TITLE:=DNS Over HTTPS Proxy
	URL:=https://github.com/mossdef-org/https-dns-proxy/
	DEPENDS:= \
		+libcares \
		+libcurl \
		+libev \
		+ca-bundle \
		+jsonfilter \
		+resolveip \
		+!BUSYBOX_DEFAULT_GREP:grep \
		+!BUSYBOX_DEFAULT_SED:sed
	CONFLICTS:=https_dns_proxy
endef

define Package/https-dns-proxy/description
Light-weight DNS-over-HTTPS, non-caching translation proxy for the RFC 8484 DoH standard.
It receives regular, unencrypted (UDP) DNS requests and resolves them via DoH resolver.
Please see https://docs.openwrt.melmac.ca/https-dns-proxy/ for more information.
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
