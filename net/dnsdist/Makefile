include $(TOPDIR)/rules.mk

PKG_NAME:=dnsdist
PKG_VERSION:=1.9.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://downloads.powerdns.com/releases/
PKG_HASH:=16bab15cad9245571806398a8e4a5dc32a92b6bb60e617c12fe958c945889c7c

PKG_MAINTAINER:=Peter van Dijk <peter.van.dijk@powerdns.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:powerdns:dnsdist

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=boost

PKG_CONFIG_DEPENDS:= \
  CONFIG_DNSDIST_GNUTLS \
  CONFIG_DNSDIST_OPENSSL

include $(INCLUDE_DIR)/package.mk

define Package/dnsdist/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=dnsdist DNS-, DOS- and abuse-aware loadbalancer $(2)
  USERID:=dnsdist:dnsdist
  DEPENDS:= \
	  +ca-bundle \
	  +libatomic \
	  +libcap \
	  +libstdcpp \
	  @HAS_LUAJIT_ARCH +luajit
  URL:=https://dnsdist.org/
  VARIANT:=$(1)
  PROVIDES:=dnsdist
endef

define Package/dnsdist/description/Default
  dnsdist is a highly DNS-, DoS- and abuse-aware loadbalancer. Its goal in life
  is to route traffic to the best server, delivering top performance to legitimate
  users while shunting or blocking abusive traffic.
endef

define Package/dnsdist/conffiles/Default
/etc/dnsdist.conf
/etc/config/dnsdist
/etc/init.d/dnsdist
endef

define Package/dnsdist/config
  source "$(SOURCE)/Config.in"
endef

define Package/dnsdist/install/Default
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/dnsdist.conf.d
	$(INSTALL_CONF) ./files/dnsdist.conf $(1)/etc/dnsdist.conf
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/dnsdist.config $(1)/etc/config/dnsdist
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dnsdist.init $(1)/etc/init.d/dnsdist
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dnsdist $(1)/usr/bin/
endef

define Package/dnsdist
  $(call Package/dnsdist/Default,mini,- minimal version with a restricted feature set)
  DEPENDS+= \
	  +DNSDIST_LIBEDIT:libedit \
	  +DNSDIST_DNSTAP:libfstrm \
	  +DNSDIST_GNUTLS:libgnutls \
	  +DNSDIST_DNS_OVER_HTTPS:libnghttp2 \
	  +DNSDIST_NET_SNMP:libnetsnmp \
	  +DNSDIST_OPENSSL:libopenssl \
	  +DNSDIST_SODIUM:libsodium \
	  +DNSDIST_LMDB:lmdb \
	  +DNSDIST_CDB:tinycdb \
	  +DNSDIST_RE2:re2
endef

Package/dnsdist/description=$(call Package/dnsdist/description/Default)
Package/dnsdist/conffiles=$(call Package/dnsdist/conffiles/Default)
Package/dnsdist/install=$(call Package/dnsdist/install/Default,$1)

define Package/dnsdist-full
  $(call Package/dnsdist/Default,full,- full version with all the features built in)
  DEPENDS+= \
	  +libedit \
	  +libfstrm \
	  +libgnutls \
	  +libnetsnmp \
	  +libnghttp2 \
	  +libopenssl \
	  +libsodium \
	  +lmdb \
	  +tinycdb \
	  +re2
endef
Package/dnsdist-full/description=$(call Package/dnsdist/description/Default)
Package/dnsdist-full/conffiles=$(call Package/dnsdist/conffiles/Default)
Package/dnsdist-full/install=$(call Package/dnsdist/install/Default,$1)

# not everything groks --disable-nls
DISABLE_NLS:=

# disable PIE for this package, see CONFIG_DNSDIST_PIE
PKG_ASLR_PIE:=0

ifneq ($(CONFIG_DNSDIST_DEBUG_SYMBOLS),)
	RSTRIP:=:
	STRIP:=:
endif

IsEnabled = $(or $(filter full,$(BUILD_VARIANT)),$(CONFIG_$(1)))

# OpenWRT's setting of CXX destroys dnsdist's -std=c++17
# --with-re2 compensates for that because it compensates for a bug in re2.pc that also destroys it
# so this addition is for the --without-re2 case
#
# none of this is pretty
TARGET_CXX+=-std=c++17
TARGET_CFLAGS+=-Os -fvisibility=hidden -flto -fno-ipa-cp -DNDEBUG
TARGET_CXXFLAGS+=-Os -fvisibility=hidden -flto -fno-ipa-cp -DNDEBUG \
	-DDISABLE_DEPRECATED_DYNBLOCK -DDISABLE_RECVMMSG -DDISABLE_NPN -DDISABLE_FALSE_SHARING_PADDING -DUSE_SINGLE_ACCEPTOR_THREAD -DOPENSSL_NO_ENGINE -DDISABLE_OPENSSL_ERROR_STRINGS \
	$(if $(call IsEnabled,DNSDIST_CARBON),,-DDISABLE_CARBON) \
	$(if $(call IsEnabled,DNSDIST_COMPLETION),,-DDISABLE_COMPLETION) \
	$(if $(call IsEnabled,DNSDIST_DEBUG_SYMBOLS),-g3,) \
	$(if $(call IsEnabled,DNSDIST_DELAY_PIPE),,-DDISABLE_DELAY_PIPE) \
	$(if $(call IsEnabled,DNSDIST_DYNBLOCKS),,-DDISABLE_DYNBLOCKS) \
	$(if $(call IsEnabled,DNSDIST_ECS_ACTIONS),,-DDISABLE_ECS_ACTIONS) \
	$(if $(call IsEnabled,DNSDIST_HASHED),,-DDISABLE_HASHED_CREDENTIALS) \
	$(if $(call IsEnabled,DNSDIST_LUA_ADVANCED),,-DDISABLE_NON_FFI_DQ_BINDINGS -DDISABLE_DOWNSTREAM_BINDINGS -DDISABLE_DNSHEADER_BINDINGS -DDISABLE_COMBO_ADDR_BINDINGS -DDISABLE_QPS_LIMITER_BINDINGS -DDISABLE_PACKETCACHE_BINDINGS -DDISABLE_CLIENT_STATE_BINDINGS -DDISABLE_DNSPACKET_BINDINGS -DDISABLE_LUA_BINDINGS_RINGS) \
	$(if $(call IsEnabled,DNSDIST_MAC),-DDNSDIST_RINGS_WITH_MACADDRESS,) \
	$(if $(call IsEnabled,DNSDIST_OCSP_STAPLING),,-DDISABLE_OCSP_STAPLING) \
	$(if $(call IsEnabled,DNSDIST_PROTOBUF),,-DDISABLE_PROTOBUF) \
	$(if $(call IsEnabled,DNSDIST_PROMETHEUS),,-DDISABLE_PROMETHEUS) \
	$(if $(call IsEnabled,DNSDIST_RULES_ALTER),,-DDISABLE_RULES_ALTERING_QUERIES) \
	$(if $(call IsEnabled,DNSDIST_SECPOLL),,-DDISABLE_SECPOLL) \
	$(if $(call IsEnabled,DNSDIST_TOP_N),,-DDISABLE_TOP_N_BINDINGS) \
	$(if $(call IsEnabled,DNSDIST_WEB),,-DDISABLE_WEB_CONFIG -DDISABLE_BUILTIN_HTML -DDISABLE_LUA_WEB_HANDLERS)

CONFIGURE_ARGS+= \
	--with-pic \
	--with-lua=luajit \
	--with-libcap \
	$(if $(call IsEnabled,DNSDIST_PIE),,--disable-hardening) \
	$(if $(call IsEnabled,DNSDIST_SODIUM),--enable-dnscrypt --with-libsodium,--disable-dnscrypt --without-libsodium) \
	$(if $(call IsEnabled,DNSDIST_DNSTAP),--enable-dnstap=yes,--enable-dnstap=no) \
	$(if $(call IsEnabled,DNSDIST_RE2),--with,--without)-re2 \
	$(if $(call IsEnabled,DNSDIST_NET_SNMP),--with,--without)-net-snmp \
	$(if $(call IsEnabled,DNSDIST_GNUTLS),--with,--without)-gnutls \
	$(if $(call IsEnabled,DNSDIST_OPENSSL),--with,--without)-libssl \
	$(if $(call IsEnabled,DNSDIST_DNS_OVER_TLS),--enable-dns-over-tls,) \
	$(if $(call IsEnabled,DNSDIST_CDB),--with,--without)-cdb \
	$(if $(call IsEnabled,DNSDIST_LMDB),--with,--without)-lmdb \
	$(if $(call IsEnabled,DNSDIST_LIBEDIT),--with,--without)-libedit \
	$(if $(call IsEnabled,DNSDIST_IPCIPHER),--enable,--disable)-ipcipher \
	$(if $(call IsEnabled,DNSDIST_EBPF),--with,--without)-ebpf \
	$(if $(call IsEnabled,DNSDIST_DNS_OVER_HTTPS),--enable-dns-over-https,) \

$(eval $(call BuildPackage,dnsdist))
$(eval $(call BuildPackage,dnsdist-full))
