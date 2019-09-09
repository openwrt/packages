#
# Copyright (C) 2008-2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tor
PKG_VERSION:=0.4.1.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://dist.torproject.org/ \
	https://archive.torproject.org/tor-package-archive
PKG_HASH:=a864e0b605fb933fcc167bf242eed4233949e8a1bf23ac8e0381b106cd920425
PKG_MAINTAINER:=Hauke Mehrtens <hauke@hauke-m.de> \
		Peter Wagner <tripolar@gmx.at>
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:torproject:tor

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/tor/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://www.torproject.org/
  USERID:=tor=52:tor=52
endef

define Package/tor/Default/description
 Tor is a toolset for a wide range of organizations and people that want to
 improve their safety and security on the Internet. Using Tor can help you
 anonymize web browsing and publishing, instant messaging, IRC, SSH, and
 more. Tor also provides a platform on which software developers can build
 new applications with built-in anonymity, safety, and privacy features.
endef

define Package/tor
$(call Package/tor/Default)
  TITLE:=An anonymous Internet communication system
  DEPENDS:=+libevent2 +libopenssl +libpthread +librt +zlib +libcap
endef

define Package/tor/description
$(call Package/tor/Default/description)
 This package contains the tor daemon.
endef

define Package/tor-gencert
$(call Package/tor/Default)
  TITLE:=Tor certificate generation
  DEPENDS:=+tor
endef

define Package/tor-gencert/description
$(call Package/tor/Default/description)
 Generate certs and keys for Tor directory authorities
endef

define Package/tor-resolve
$(call Package/tor/Default)
  TITLE:=tor hostname resolve
  DEPENDS:=+tor
endef

define Package/tor-resolve/description
$(call Package/tor/Default/description)
 Resolve a hostname to an IP address via tor
endef

define Package/tor-geoip
$(call Package/tor/Default)
  TITLE:=GeoIP db for tor
  DEPENDS:=+tor
endef

define Package/tor-geoip/description
$(call Package/tor/Default/description)
 This package contains a GeoIP database mapping IP addresses to countries.
endef

define Package/tor/conffiles
/etc/tor/torrc
/var/lib/tor/fingerprint
/var/lib/tor/keys/*
endef

CONFIGURE_ARGS += \
	--with-libevent-dir="$(STAGING_DIR)/usr" \
	--with-openssl-dir="$(STAGING_DIR)/usr" \
	--with-zlib-dir="$(STAGING_DIR)/usr" \
	--disable-asciidoc \
	--disable-seccomp \
	--disable-libscrypt \
	--disable-unittests \
	--disable-lzma \
	--disable-zstd \
	--with-tor-user=tor \
	--with-tor-group=tor

TARGET_CFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections -flto

ifneq ($(CONFIG_SSP_SUPPORT),y)
	CONFIGURE_ARGS += \
		--disable-gcc-hardening
else
	EXTRA_CFLAGS += $(FPIC)
endif

CONFIGURE_VARS += \
	CROSS_COMPILE="yes"

define Package/tor/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tor $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tor.init $(1)/etc/init.d/tor
	$(INSTALL_DIR) $(1)/etc/tor
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/tor/torrc.sample $(1)/etc/tor/torrc
endef

define Package/tor-gencert/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tor-gencert $(1)/usr/sbin/
endef

define Package/tor-resolve/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tor-resolve $(1)/usr/sbin/
endef

define Package/tor-geoip/install
	$(INSTALL_DIR) $(1)/usr/share/tor
	$(INSTALL_DATA) \
	  $(PKG_INSTALL_DIR)/usr/share/tor/geoip \
	  $(PKG_INSTALL_DIR)/usr/share/tor/geoip6 \
	$(1)/usr/share/tor/
endef

$(eval $(call BuildPackage,tor))
$(eval $(call BuildPackage,tor-gencert))
$(eval $(call BuildPackage,tor-resolve))
$(eval $(call BuildPackage,tor-geoip))
