#
# Copyright (C) 2016 OpenWrt.org
# Copyright (C) 2012-2016 Black Roland and contributors (https://github.com/black-roland/exOpenWrt/graphs/contributors)
# Copyright (C) 2011-2012 Entware
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dnscrypt-proxy
PKG_VERSION:=1.9.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://download.dnscrypt.org/dnscrypt-proxy \
https://github.com/jedisct1/dnscrypt-proxy/releases/download/$(PKG_VERSION)
PKG_HASH:=e89f5b9039979ab392302faf369ef7593155d5ea21580402a75bbc46329d1bb6
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Damiano Renfer <damiano.renfer@gmail.com>
PKG_LICENSE:=ISC
PKG_CONFIG_DEPENDS:= \
	CONFIG_DNSCRYPT_ENABLE_PLUGINS

include $(INCLUDE_DIR)/package.mk

define Package/dnscrypt-proxy/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  URL:=http://dnscrypt.org/
  MAINTAINER:=Damiano Renfer <damiano.renfer@gmail.com>
endef

define Package/dnscrypt-proxy
  $(call Package/dnscrypt-proxy/Default)
  DEPENDS:=+libsodium +dnscrypt-proxy-resolvers +DNSCRYPT_ENABLE_PLUGINS:libltdl \
	+DNSCRYPT_ENABLE_PLUGINS:libldns
  TITLE:=A tool for securing communications between a client and a DNS resolver
endef

define Package/dnscrypt-proxy/description
  dnscrypt-proxy provides local service which can be used directly as your
  local resolver or as a DNS forwarder, encrypting and authenticating requests
  using the DNSCrypt protocol and passing them to an upstream server.
  The DNSCrypt protocol uses high-speed high-security elliptic-curve cryptography
  and is very similar to DNSCurve, but focuses on securing communications between
  a client and its first-level resolver.
endef

define Package/dnscrypt-proxy-resolvers
  $(call Package/dnscrypt-proxy/Default)
  TITLE:=Package with current list of dnscrypt-proxy resolvers
  VERSION:=$(PKG_VERSION)+git-20161129-f17bace-$(PKG_RELEASE)
endef

define Package/dnscrypt-proxy-resolvers/description
  Package with current list of dnscrypt-proxy resolvers.
endef

define Package/hostip
  $(call Package/dnscrypt-proxy/Default)
  DEPENDS:=+libsodium
  TITLE:=Resolver to IPv4 or IPv6 addresses
endef

define Package/hostip/description
  The DNSCrypt proxy ships with a simple tool named hostip that resolves a name
  to IPv4 or IPv6 addresses.
endef

define Package/dnscrypt-proxy/config
	source "$(SOURCE)/Config.in"
endef

define Build/Configure
	$(call Build/Configure/Default, \
	--prefix=/usr \
	--disable-ssp \
	$(if $(CONFIG_DNSCRYPT_ENABLE_PLUGINS),,--disable-plugins) \
	)
endef

TARGET_CFLAGS += \
	-fomit-frame-pointer \
	-fdata-sections \
	-ffunction-sections

TARGET_LDFLAGS += \
	-Wl,-gc-sections

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"

define Package/dnscrypt-proxy/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/dnscrypt-proxy $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dnscrypt-proxy.init $(1)/etc/init.d/dnscrypt-proxy
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/dnscrypt-proxy.config $(1)/etc/config/dnscrypt-proxy
	$(if $(CONFIG_DNSCRYPT_ENABLE_PLUGINS), \
		$(INSTALL_DIR) $(1)/usr/lib/dnscrypt-proxy; \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/dnscrypt-proxy/libdcplugin_example_cache.so $(1)/usr/lib/dnscrypt-proxy/; \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/dnscrypt-proxy/libdcplugin_example_ldns_aaaa_blocking.so $(1)/usr/lib/dnscrypt-proxy/; \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/dnscrypt-proxy/libdcplugin_example_ldns_blocking.so $(1)/usr/lib/dnscrypt-proxy/; \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/dnscrypt-proxy/libdcplugin_example_logging.so $(1)/usr/lib/dnscrypt-proxy/)
endef

define Package/dnscrypt-proxy-resolvers/install
	$(INSTALL_DIR) $(1)/usr/share/dnscrypt-proxy
	$(CP) ./files/dnscrypt-resolvers.csv $(1)/usr/share/dnscrypt-proxy/
endef

define Package/dnscrypt-proxy/conffiles
/etc/config/dnscrypt-proxy
endef

define Package/hostip/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/hostip $(1)/usr/bin/
endef

$(eval $(call BuildPackage,dnscrypt-proxy))
$(eval $(call BuildPackage,dnscrypt-proxy-resolvers))
$(eval $(call BuildPackage,hostip))
