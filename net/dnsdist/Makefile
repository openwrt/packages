include $(TOPDIR)/rules.mk

PKG_NAME:=dnsdist
PKG_VERSION:=1.3.3
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://downloads.powerdns.com/releases/
PKG_HASH:=9fb24f9032025955169f3c6e9b0a05b6aa9d6441ec47da08d22de1c1aa23e8cf

PKG_MAINTAINER:=James Taylor <james@jtaylor.id.au>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_ASLR_PIE:=0
PKG_BUILD_DEPENDS:=protobuf/host

PKG_CONFIG_DEPENDS:= \
  CONFIG_DNSDIST_GNUTLS \
  CONFIG_DNSDIST_OPENSSL

include $(INCLUDE_DIR)/package.mk

define Package/dnsdist/config
comment "SSL support"

choice
        prompt "Selected SSL library"
        default DNSDIST_OPENSSSL

        config DNSDIST_OPENSSL
                bool "OpenSSL"

        config DNSDIST_GNUTLS
                bool "GnuTLS"

        config DNSDIST_NOSSL
                bool "No SSL support"

endchoice
endef

define Package/dnsdist
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=dnsdist DNS-, DOS- and abuse-aware loadbalancer
  DEPENDS:=+DNSDIST_OPENSSL:libopenssl +DNSDIST_GNUTLS:libgnutls +protobuf +re2 +libedit +libfstrm +libsodium +lua +boost +libnetsnmp +libatomic
  URL:=https://dnsdist.org/
endef

define Package/dnsdist/description
  dnsdist is a highly DNS-, DoS- and abuse-aware loadbalancer. Its goal in life
  is to route traffic to the best server, delivering top performance to legitimate
  users while shunting or blocking abusive traffic.
endef

define Package/dnsdist/conffiles
/etc/dnsdist.conf
/etc/config/dnsdist
/etc/init.d/dnsdist
endef

CONFIGURE_ARGS+= \
	--enable-dnscrypt \
	$(if $(CONFIG_DNSDIST_NOSSL),,--enable-dns-over-tls) \
	--enable-fstrm \
	--enable-libsodium \
	--enable-protobuf \
	--enable-re2 \
	--with-lua=lua \
	--with-net-snmp \
        $(if $(CONFIG_DNSDIST_GNUTLS),--enable,--disable)-gnutls \
        $(if $(CONFIG_DNSDIST_OPENSSL),--enable,--disable)-libssl

define Package/dnsdist/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/dnsdist.conf $(1)/etc/dnsdist.conf
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/dnsdist.config $(1)/etc/config/dnsdist
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dnsdist.init $(1)/etc/init.d/dnsdist
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dnsdist $(1)/usr/bin/
endef

$(eval $(call BuildPackage,dnsdist))
