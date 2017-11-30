#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=squid-4x
PKG_VERSION:=4.0.21
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Marko Ratkaj <marko.ratkaj@sartura.hr>

PKG_SOURCE:=squid-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://www.squid-cache.org/Versions/v4/
PKG_HASH:=154d8ebdfdd004f113899b71325dcc401cf07ad8736701032d531c7af1908e33
PKG_BUILD_DIR:=$(BUILD_DIR)/squid-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/squid-4x/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=http://www.squid-cache.org/
endef

define Package/squid-4x
  $(call Package/squid-4x/Default)
  MENU:=1
  DEPENDS:=+libpthread +librt +libltdl +libstdcpp +libatomic
  DEPENDS+= +SQUID_use-gnutls:libgnutls +!SQUID_use-gnutls:libopenssl
  DEPENDS+= +SQUID_with-libcap:libcap
  DEPENDS+= +SQUID_with-nettle:libnettle
  DEPENDS+= +SQUID_with-expat:libexpat
  DEPENDS+= +SQUID_with-libxml2:libxml2
  TITLE:=Full-featured Web caching proxy (Beta)
  USERID:=squid=137:squid=137
endef

define Package/squid-4x/description
  $(TITLE)
endef

define Package/squid-4x/config
	help
		Squid is a caching proxy for the Web supporting HTTP, HTTPS, FTP, and more.
		It reduces bandwidth and improves response times by caching and reusing
		frequently-requested web pages.
		Run as : $(USERID)
		Version: $(PKG_VERSION)
		Home   : $(URL)
		Maintainer: $(PKG_MAINTAINER)

	source "$(SOURCE)/Config.in"
endef


define Package/squid-4x-mod-cachemgr
  $(call Package/squid-4x/Default)
  DEPENDS:=squid-4x
  TITLE:=Web based proxy manager and reporting tool
endef

CONFIGURE_ARGS += \
	--datadir=/usr/share/squid \
	--libexecdir=/usr/lib/squid \
	--sysconfdir=/etc/squid \
	--disable-arch-native \
	--with-dl \
	--enable-shared \
	--disable-static \
	--config-cache \
	--enable-cache-digests \
	--enable-delay-pools \
	--enable-kill-parent-hack \
	--enable-linux-netfilter \
	--without-netfilter-conntrack \
	--disable-unlinkd \
	--enable-x-accelerator-vary \
	--with-pthreads \
	--enable-ssl \
	--disable-translation \
	--disable-auto-locale \
	--enable-epoll \
	--with-maxfd=2048 \
	--disable-ecap \
	--disable-external-acl-helpers \
	--disable-ident-lookups \
	--without-mit-krb5

CONFIGURE_ARGS += \
	$(if $(CONFIG_SQUID_auth-basic),--enable,--disable)-auth-basic \
	$(if $(CONFIG_SQUID_auth-digest),--enable,--disable)-auth-digest \
	$(if $(CONFIG_SQUID_auth-ntlm),--enable,--disable)-auth-ntlm \
	$(if $(CONFIG_SQUID_auth-negotiate),--enable,--disable)-auth-negotiate \
	$(if $(CONFIG_SQUID_enable-ipv6),--enable,--disable)-dlmalloc \
	$(if $(CONFIG_SQUID_enable-ipv6),--enable,--disable)-ipv6 \
	$(if $(CONFIG_SQUID_enable-ssl-crtd),--enable-ssl-crtd) \
	$(if $(CONFIG_SQUID_use-gnutls),--with,--without)-gnutls \
	$(if $(CONFIG_SQUID_use-gnutls),--without-openssl) \
	$(if $(CONFIG_SQUID_use-gnutls),,--with-openssl="$(STAGING_DIR)/usr") \
	$(if $(CONFIG_SQUID_enable-icmp),--enable,--disable)-icmp \
	$(if $(CONFIG_SQUID_enable-icap-client),--enable,--disable)-icap-client \
	$(if $(CONFIG_SQUID_enable-snmp),--enable,--disable)-snmp \
	$(if $(CONFIG_SQUID_with-libcap),--with,--without)-libcap \
	$(if $(CONFIG_SQUID_with-nettle),--with,--without)-nettle \
	$(if $(CONFIG_SQUID_with-expat),--with,--without)-expat \
	$(if $(CONFIG_SQUID_with-libxml2),--with,--without)-libxml2

CONFIGURE_VARS += \
	ac_cv_header_linux_netfilter_ipv4_h=yes

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/lib all
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		install
endef

define Package/squid-4x/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/squid $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/lib/squid
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/squid/* $(1)/usr/lib/squid

	$(INSTALL_DIR) $(1)/etc/squid
	$(CP) $(PKG_INSTALL_DIR)/etc/squid/* $(1)/etc/squid/
	$(CP) ./files/squid.conf $(1)/etc/squid/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/squid.init $(1)/etc/init.d/squid

	$(INSTALL_DIR) $(1)/usr/share/squid/
	$(INSTALL_DIR) $(1)/usr/share/squid/icons/
	$(INSTALL_DIR) $(1)/usr/share/squid/errors/templates/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/squid/mib.txt $(1)/usr/share/squid/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/squid/icons/* $(1)/usr/share/squid/icons/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/share/squid/errors/templates/* \
		$(1)/usr/share/squid/errors/templates/
endef

define Package/squid-4x-mod-cachemgr/install
	$(INSTALL_DIR) $(1)/www/cgi-bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/squid/cachemgr.cgi $(1)/www/cgi-bin/
endef

$(eval $(call BuildPackage,squid-4x))
$(eval $(call BuildPackage,squid-4x-mod-cachemgr))
