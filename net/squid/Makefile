#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=squid
PKG_VERSION:=7.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/squid-cache/squid/releases/download/SQUID_$(subst .,_,$(PKG_VERSION))
PKG_HASH:=763b5a78561cedc4e47634fa42b8e6b8d46c87c949a151b4e7ac2396d2f97dea

PKG_MAINTAINER:=Marko Ratkaj <markoratkaj@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_CPE_ID:=cpe:/a:squid-cache:squid

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/squid/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=https://www.squid-cache.org/
endef

define Package/squid
  $(call Package/squid/Default)
  MENU:=1
  DEPENDS:= +USE_GLIBC:libcrypt-compat +USE_GLIBC:libbsd +libpthread +librt +libltdl +libstdcpp +libatomic
  DEPENDS+= +SQUID_use-gnutls:libgnutls +SQUID_use-openssl:libopenssl
  DEPENDS+= +SQUID_with-libcap:libcap
  DEPENDS+= +SQUID_with-nettle:libnettle
  DEPENDS+= +SQUID_with-expat:libexpat
  DEPENDS+= +SQUID_with-libxml2:libxml2
  USERID:=squid=137:squid=137
  TITLE:=full-featured Web proxy cache
endef

define Package/squid/description
  Squid is a caching proxy for the Web supporting HTTP, HTTPS, FTP, and more.
  It reduces bandwidth and improves response times by caching and reusing
  frequently-requested web pages.
endef

define Package/squid/config
  source "$(SOURCE)/Config.in"
endef

define Package/squid/conffiles
/etc/config/squid
/etc/squid/squid.conf
endef

CONFIGURE_ARGS += \
	BUILDCXX=$(HOSTCXX_NOCACHE) \
	BUILDCXXFLAGS="$(HOST_CXXFLAGS) $(HOST_CPPFLAGS) -std=c++17" \
	--datadir=/usr/share/squid \
	--libexecdir=/usr/lib/squid \
	--sysconfdir=/etc/squid \
	--disable-static \
	--enable-delay-pools \
	--enable-cache-digests \
	--enable-linux-netfilter \
	--disable-unlinkd \
	--enable-x-accelerator-vary \
	--disable-auto-locale \
	--enable-epoll \
	--with-filedescriptors=2048 \
	--disable-external-acl-helpers \
	--disable-arch-native \
	--without-mit-krb5 \
	--without-heimdal-krb5 \
	--without-netfilter-conntrack \
	--disable-ident-lookups \
	$(if $(CONFIG_SQUID_auth-basic),--enable,--disable)-auth-basic \
	$(if $(CONFIG_SQUID_auth-digest),--enable,--disable)-auth-digest \
	$(if $(CONFIG_SQUID_auth-ntlm),--enable,--disable)-auth-ntlm \
	$(if $(CONFIG_SQUID_auth-negotiate),--enable,--disable)-auth-negotiate \
	$(if $(CONFIG_SQUID_enable-ipv6),--enable,--disable)-ipv6 \
	$(if $(CONFIG_SQUID_enable-ssl-crtd),--enable-ssl-crtd) \
	$(if $(CONFIG_SQUID_use-gnutls),--with,--without)-gnutls \
	$(if $(CONFIG_SQUID_use-gnutls),--without-openssl) \
	$(if $(CONFIG_SQUID_use-gnutls),,--with-openssl="$(STAGING_DIR)/usr") \
	$(if $(CONFIG_SQUID_enable-icmp),--enable,--disable)-icmp \
	$(if $(CONFIG_SQUID_enable-icap-client),--enable,--disable)-icap-client \
	$(if $(CONFIG_SQUID_enable-snmp),--enable,--disable)-snmp \
	$(if $(CONFIG_SQUID_with-libcap),--with,--without)-cap \
	$(if $(CONFIG_SQUID_with-nettle),--with,--without)-nettle \
	$(if $(CONFIG_SQUID_with-expat),--with,--without)-expat \
	$(if $(CONFIG_SQUID_with-libxml2),--with,--without)-xml2

CONFIGURE_VARS += \
	ac_cv_header_linux_netfilter_ipv4_h=yes \
	squid_cv_epoll_works=yes

define Package/squid/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/squid $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/lib/squid
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/squid/* $(1)/usr/lib/squid/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/squid.config $(1)/etc/config/squid

	$(INSTALL_DIR) $(1)/etc/squid
	$(CP) $(PKG_INSTALL_DIR)/etc/squid/* $(1)/etc/squid/
	$(INSTALL_CONF) ./files/squid.conf $(1)/etc/squid/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/squid.init $(1)/etc/init.d/squid

	$(INSTALL_DIR) $(1)/usr/share/squid/icons/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/squid/icons/* $(1)/usr/share/squid/icons/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/squid/mib.txt $(1)/usr/share/squid/

	$(INSTALL_DIR) $(1)/usr/share/squid/errors/templates/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/squid/errors/templates/* $(1)/usr/share/squid/errors/templates/
endef

$(eval $(call BuildPackage,squid))
