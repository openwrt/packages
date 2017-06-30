include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocksR-libev
PKG_VERSION:=v20170613
PKG_RELEASE:=1pre

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE).tar.gz
PKG_SOURCE_URL:=https://github.com/breakwa11/shadowsocks-libev.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=f713aa981169d35ff9483b295d1209c35117d70c
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MAINTAINER:=breakwa11

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/shadowsocksr-libev/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Lightweight Secured Socks5 Proxy
  URL:=https://github.com/breakwa11/shadowsocks-libev
endef

# default packages
define Package/shadowsocksr-libev
  $(call Package/shadowsocksr-libev/Default)
  TITLE+= (OpenSSL)
  VARIANT:=openssl
  DEPENDS:=+libopenssl +libpthread +libpcre +zlib
endef

define Package/shadowsocksr-libev-polarssl
  $(call Package/shadowsocksr-libev/Default)
  TITLE+= (PolarSSL)
  VARIANT:=polarssl
  DEPENDS:=+libpolarssl +libpthread +libpcre
endef

define Package/shadowsocksr-libev-mbedtls
  $(call Package/shadowsocksr-libev/Default)
  TITLE+= (mbedTLS)
  VARIANT:=mbedtls
  DEPENDS:=+libmbedtls +libpthread +libpcre
endef

# gfwlist packages
define Package/shadowsocksr-libev-gfwlist
  $(call Package/shadowsocksr-libev/Default)
  TITLE+= (OpenSSL)
  VARIANT:=openssl
  DEPENDS:=+libopenssl +libpthread +libpcre +zlib +dnsmasq-full +ipset +dns-forwarder
endef

define Package/shadowsocksr-libev-gfwlist-polarssl
  $(call Package/shadowsocksr-libev/Default)
  TITLE+= (PolarSSL)
  VARIANT:=polarssl
  DEPENDS:=+libpolarssl +libpthread +libpcre +dnsmasq-full +ipset +dns-forwarder
endef

define Package/shadowsocksr-libev-gfwlist-mbedtls
  $(call Package/shadowsocksr-libev/Default)
  TITLE+= (mbedTLS)
  VARIANT:=mbedtls
  DEPENDS:=+libmbedtls +libpthread +libpcre +dnsmasq-full +ipset +dns-forwarder
endef

define Package/shadowsocksr-libev/description
ShadowsocksR-libev is a lightweight secured socks5 proxy for embedded devices and low end boxes.
endef

Package/shadowsocksr-libev-polarssl/description=$(Package/shadowsocksr-libev/description)
Package/shadowsocksr-libev-mbedtls/description=$(Package/shadowsocksr-libev/description)

Package/shadowsocksr-libev-gfwlist/description=$(Package/shadowsocksr-libev/description)
Package/shadowsocksr-libev-gfwlist-mbedtls/description=$(Package/shadowsocksr-libev/description)
Package/shadowsocksr-libev-gfwlist-polarssl/description=$(Package/shadowsocksr-libev/description)

define Package/shadowsocksr-libev/conffiles
/etc/shadowsocksr.json
endef

Package/shadowsocksr-libev-polarssl/conffiles = $(Package/shadowsocksr-libev/conffiles)
Package/shadowsocksr-libev-mbedtls/conffiles = $(Package/shadowsocksr-libev/conffiles)

Package/shadowsocksr-libev-gfwlist/conffiles = $(Package/shadowsocksr-libev/conffiles)
Package/shadowsocksr-libev-gfwlist-mbedtls/conffiles = $(Package/shadowsocksr-libev/conffiles)
Package/shadowsocksr-libev-gfwlist-polarssl/conffiles = $(Package/shadowsocksr-libev/conffiles)

define Package/shadowsocksr-libev-gfwlist/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/firewall restart
	/etc/init.d/shadowsocksr restart
	/etc/init.d/dns-forwarder restart
	/etc/init.d/dnsmasq restart
fi
exit 0
endef

Package/shadowsocksr-libev-gfwlist-mbedtls/postinst = $(Package/shadowsocksr-libev-gfwlist/postinst)
Package/shadowsocksr-libev-gfwlist-polarssl/postinst = $(Package/shadowsocksr-libev-gfwlist/postinst)

CONFIGURE_ARGS += --disable-ssp --disable-documentation --disable-assert

ifeq ($(BUILD_VARIANT),polarssl)
	CONFIGURE_ARGS += --with-crypto-library=polarssl
endif

ifeq ($(BUILD_VARIANT),mbedtls)
	CONFIGURE_ARGS += --with-crypto-library=mbedtls
endif

define Package/shadowsocksr-libev/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/shadowsocksr $(1)/etc/init.d/shadowsocksr
	$(INSTALL_CONF) ./files/shadowsocksr.json $(1)/etc/shadowsocksr.json
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-local $(1)/usr/bin/ssr-local
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-redir $(1)/usr/bin/ssr-redir
	#$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-tunnel $(1)/usr/bin/ssr-tunnel
endef

Package/shadowsocksr-libev-polarssl/install=$(Package/shadowsocksr-libev/install)
Package/shadowsocksr-libev-mbedtls/install=$(Package/shadowsocksr-libev/install)

define Package/shadowsocksr-libev-gfwlist/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/shadowsocksr-gfwlist $(1)/etc/init.d/shadowsocksr
	$(INSTALL_CONF) ./files/shadowsocksr-gfwlist.json $(1)/etc/shadowsocksr.json
	$(INSTALL_DIR) $(1)/usr/bin
	#$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-local $(1)/usr/bin/ssr-local
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-redir $(1)/usr/bin/ssr-redir
	#$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-tunnel $(1)/usr/bin/ssr-tunnel
	$(INSTALL_BIN) ./files/ssr-watchdog $(1)/usr/bin/ssr-watchdog
	
	#patch dnsmasq, add ipset gfwlist 
	$(INSTALL_CONF) ./files/dnsmasq.conf $(1)/etc/dnsmasq.conf
	$(INSTALL_DIR) $(1)/etc/dnsmasq.d
	$(INSTALL_CONF) ./files/gfw_list.conf $(1)/etc/dnsmasq.d/gfw_list.conf
	$(INSTALL_CONF) ./files/custom_list.conf $(1)/etc/dnsmasq.d/custom_list.conf
	
	#patch firewall rule, create ipset gfwlist & redirect traffic
	$(INSTALL_CONF) ./files/firewall.user $(1)/etc/firewall.user
	
	#patch dns-forwarder
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/dns-forwarder.config $(1)/etc/config/dns-forwarder
	
	#install luci for ssr
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_CONF) ./files/shadowsocksr-libev.lua $(1)/usr/lib/lua/luci/controller/shadowsocksr-libev.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/shadowsocksr-libev
	$(INSTALL_CONF) ./files/shadowsocksr-libev-general.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocksr-libev/shadowsocksr-libev-general.lua
	$(INSTALL_CONF) ./files/shadowsocksr-libev-custom.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocksr-libev/shadowsocksr-libev-custom.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/shadowsocksr-libev
	$(INSTALL_CONF) ./files/gfwlistr.htm $(1)/usr/lib/lua/luci/view/shadowsocksr-libev/gfwlistr.htm
	$(INSTALL_CONF) ./files/watchdogr.htm $(1)/usr/lib/lua/luci/view/shadowsocksr-libev/watchdogr.htm
endef

Package/shadowsocksr-libev-gfwlist-polarssl/install=$(Package/shadowsocksr-libev-gfwlist/install)
Package/shadowsocksr-libev-gfwlist-mbedtls/install=$(Package/shadowsocksr-libev-gfwlist/install)

$(eval $(call BuildPackage,shadowsocksr-libev))
$(eval $(call BuildPackage,shadowsocksr-libev-polarssl))
$(eval $(call BuildPackage,shadowsocksr-libev-mbedtls))

$(eval $(call BuildPackage,shadowsocksr-libev-gfwlist))
$(eval $(call BuildPackage,shadowsocksr-libev-gfwlist-polarssl))
$(eval $(call BuildPackage,shadowsocksr-libev-gfwlist-mbedtls))
