#
# Copyright (C) 2008-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tor
PKG_VERSION:=0.2.7.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.torproject.org/dist \
	https://archive.torproject.org/tor-package-archive
PKG_MD5SUM:=cc19107b57136a68e8c563bf2d35b072
PKG_MAINTAINER:=Hauke Mehrtens <hauke@hauke-m.de>
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=libminiupnpc libnatpmp
PKG_INSTALL:=1

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
  DEPENDS:=+libevent2 +libopenssl +libpthread +librt
endef

define Package/tor/description
$(call Package/tor/Default/description)
 This package contains the tor daemon.
endef

define Package/tor-fw-helper
$(call Package/tor/Default)
  TITLE:=Firewall helper for tor
  DEPENDS:=+tor +libminiupnpc +libnatpmp
endef

define Package/tor-fw-helper/description
$(call Package/tor/Default/description)
 This package contains a helper for automatically configuring port forwarding.
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
endef

CONFIGURE_ARGS += \
	--with-libevent-dir="$(STAGING_DIR)/usr" \
	--with-ssl-dir="$(STAGING_DIR)/usr" \
	--enable-upnp \
	--with-libminiupnpc-dir="$(STAGING_DIR)/usr" \
	--enable-nat-pmp \
	--with-libnatpmp-dir="$(STAGING_DIR)/usr" \
	--disable-asciidoc \
	--disable-seccomp

ifneq ($(CONFIG_SSP_SUPPORT),y)
	CONFIGURE_ARGS += \
		--disable-gcc-hardening
	MAKE_FLAGS += \
		CFLAGS="$(TARGET_CFLAGS) -std=gnu99"
else
	MAKE_FLAGS += \
		CFLAGS="$(TARGET_CFLAGS) -fPIC -std=gnu99"	
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

define Package/tor-fw-helper/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tor-fw-helper $(1)/usr/bin/
endef

define Package/tor-geoip/install
	$(INSTALL_DIR) $(1)/usr/share/tor
	$(CP) $(PKG_INSTALL_DIR)/usr/share/tor/geoip $(1)/usr/share/tor/
endef

$(eval $(call BuildPackage,tor))
$(eval $(call BuildPackage,tor-fw-helper))
$(eval $(call BuildPackage,tor-geoip))
