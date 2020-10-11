include $(TOPDIR)/rules.mk

PKG_NAME:=dnsdist
PKG_VERSION:=1.5.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://downloads.powerdns.com/releases/
PKG_HASH:=cae759729a87703f4d09b0ed4227cb224aaaa252fa92f2432fd7116f560afbf1

PKG_MAINTAINER:=James Taylor <james@jtaylor.id.au>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:powerdns:dnsdist

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_ASLR_PIE:=0
PKG_BUILD_DEPENDS:=protobuf/host

PKG_CONFIG_DEPENDS:= \
  CONFIG_DNSDIST_GNUTLS \
  CONFIG_DNSDIST_OPENSSL

include $(INCLUDE_DIR)/package.mk

define Package/dnsdist/config
menu "Configuration"
	depends on PACKAGE_dnsdist

	comment "SSL Support"
	choice
		prompt "Selected SSL library"
		default DNSDIST_OPENSSL

		config DNSDIST_OPENSSL
			bool "OpenSSL"

		config DNSDIST_GNUTLS
			bool "GnuTLS"

		config DNSDIST_NOSSL
			bool "No SSL support"

	endchoice

	comment "DNS over HTTPS/TLS Support"
	depends on !DNSDIST_NOSSL

	config DNSDIST_DNS_OVER_HTTPS
	depends on DNSDIST_OPENSSL
	depends on !DNSDIST_NOSSL
		bool "DNS over HTTPS Support"
		help
			"Enables DNS over HTTPS Support for dnsdist"
		default y

	config DNSDIST_DNS_OVER_TLS
	depends on !DNSDIST_NOSSL
		bool "DNS over TLS Support"
		help
			"Enabled DNS over TLS Support for dnsdist"
		default y
endmenu
endef

define Package/dnsdist
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=dnsdist DNS-, DOS- and abuse-aware loadbalancer
  DEPENDS:= \
	  +DNSDIST_DNS_OVER_HTTPS:libh2o-evloop \
	  +DNSDIST_GNUTLS:libgnutls \
	  +DNSDIST_OPENSSL:libopenssl \
	  +boost \
	  +libatomic \
	  +libcap \
	  +libedit \
	  +libfstrm \
	  +libnetsnmp \
	  +libsodium \
	  +lmdb \
	  +lua \
	  +protobuf \
	  +re2 \
	  +tinycdb
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
	--enable-dnstap \
	--with-libsodium \
	--with-pic \
	--with-protobuf \
	--with-re2 \
	--with-lua=lua \
	--with-net-snmp \
	$(if $(CONFIG_DNSDIST_GNUTLS),--with,--without)-gnutls \
	$(if $(CONFIG_DNSDIST_OPENSSL),--with,--without)-libssl \
	$(if $(CONFIG_DNSDIST_DNS_OVER_TLS),--enable-dns-over-tls,) \
	$(if $(CONFIG_DNSDIST_DNS_OVER_HTTPS),--enable-dns-over-https,)

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
