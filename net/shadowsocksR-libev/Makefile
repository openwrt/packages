include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocksR-libev
PKG_VERSION:=v20170802
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE).tar.gz
PKG_SOURCE_URL:=https://github.com/shadowsocksr-rm/shadowsocksr-libev.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=a32c032cb1e424686748fb4fa3a2beae1b342334
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
    TITLE+= (mbedTLS)
    VARIANT:=mbedtls
    DEPENDS:=+libmbedtls +libpthread +libpcre
endef

define Package/shadowsocksr-libev/description
ShadowsocksR-libev is a lightweight secured socks5 proxy for embedded devices and low end boxes.
Build the binary for self usage, no luci, no gfw.
endef

define Package/shadowsocksr-libev/conffiles
/etc/shadowsocksr.json
endef

CONFIGURE_ARGS += --disable-ssp --disable-documentation --disable-assert --with-crypto-library=mbedtls

define Package/shadowsocksr-libev/install
    $(INSTALL_DIR) $(1)/etc/init.d
    $(INSTALL_BIN) ./files/shadowsocksr $(1)/etc/init.d/shadowsocksr
    $(INSTALL_CONF) ./files/shadowsocksr.json $(1)/etc/shadowsocksr.json
    $(INSTALL_DIR) $(1)/usr/bin
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-local $(1)/usr/bin/ssr-local
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-redir $(1)/usr/bin/ssr-redir
    #$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-tunnel $(1)/usr/bin/ssr-tunnel
endef

$(eval $(call BuildPackage,shadowsocksr-libev))