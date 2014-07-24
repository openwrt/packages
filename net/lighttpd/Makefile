#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lighttpd
PKG_VERSION:=1.4.35
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://download.lighttpd.net/lighttpd/releases-1.4.x
PKG_MD5SUM:=c7ae774eab4cb7ac85e41b712f4ee9ba

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lighttpd/Default
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  URL:=http://www.lighttpd.net/
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
endef

define Package/lighttpd
  $(call Package/lighttpd/Default)
  MENU:=1
  DEPENDS:=+LIGHTTPD_SSL:libopenssl +libpcre +libpthread
  TITLE:=A flexible and lightweight web server
endef

define Package/lighttpd/config
config LIGHTTPD_SSL
	bool "SSL support"
	depends on PACKAGE_lighttpd
	default y
	help
	  Implements SSL support in lighttpd (using libopenssl). This
	  option is required if you enable the SSL engine in your
	  lighttpd confguration file.
endef

define Package/lighttpd-mod-access
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Access restrictions module
endef

define Package/lighttpd-mod-accesslog
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Access logging module
endef

define Package/lighttpd-mod-alias
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Directory alias module
endef

define Package/lighttpd-mod-auth
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Authentication module
endef

define Package/lighttpd-mod-cgi
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=CGI module
endef

define Package/lighttpd-mod-cml
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Cache Meta Language module
endef

define Package/lighttpd-mod-compress
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd +zlib
  TITLE:=Compress output module
endef

define Package/lighttpd-mod-evasive
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Evasive module
endef

define Package/lighttpd-mod-evhost
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Exnhanced Virtual-Hosting module
endef

define Package/lighttpd-mod-expire
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Expire module
endef

define Package/lighttpd-mod-extforward
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Extract client IP module
endef

define Package/lighttpd-mod-fastcgi
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=FastCGI module
endef

define Package/lighttpd-mod-flv-streaming
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=flv streaming module
endef

define Package/lighttpd-mod-magnet
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=magnet module
endef

define Package/lighttpd-mod-mysql-vhost
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd +libmysqlclient
  TITLE:=Mysql virtual hosting module
endef

define Package/lighttpd-mod-proxy
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Proxy module
endef

define Package/lighttpd-mod-redirect
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd +libpcre
  TITLE:=URL redirection module
endef

define Package/lighttpd-mod-rewrite
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd +libpcre
  TITLE:=URL rewriting module
endef

define Package/lighttpd-mod-rrdtool
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=rrdtool module
endef

define Package/lighttpd-mod-scgi
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=SCGI module
endef

define Package/lighttpd-mod-secdownload
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Secure and fast download module
endef

define Package/lighttpd-mod-setenv
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Environment variable setting module
endef

define Package/lighttpd-mod-simple-vhost
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Simple virtual hosting module
endef

define Package/lighttpd-mod-ssi
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd +libpcre
  TITLE:=SSI module
endef

define Package/lighttpd-mod-status
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=Server status display module
endef

define Package/lighttpd-mod-trigger-b4-dl
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd +libpcre
  TITLE:=Trigger before download module
endef

define Package/lighttpd-mod-userdir
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=User directory module
endef

define Package/lighttpd-mod-usertrack
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd
  TITLE:=User tracking module
endef

define Package/lighttpd-mod-webdav
  $(call Package/lighttpd/Default)
  DEPENDS:=lighttpd +libsqlite3 +libuuid +libxml2
  TITLE:=WebDAV module
endef

CONFIGURE_ARGS+= \
	--libdir=/usr/lib/lighttpd \
	--sysconfdir=/etc/lighttpd \
	--enable-shared \
	--enable-static \
	--disable-rpath \
	--without-attr \
	--without-bzip2 \
	--without-fam \
	--without-gdbm \
	--without-ldap \
	--without-lua \
	--without-memcache \
	--without-mysql \
	--with-pcre \
	--without-valgrind \
	 $(call autoconf_bool,CONFIG_IPV6,ipv6)

CONFIGURE_VARS+= \
	PCRE_LIB="-lpcre" \

ifneq ($(strip $(CONFIG_LIGHTTPD_SSL)),)
  CONFIGURE_ARGS+= \
	--with-openssl="$(STAGING_DIR)/usr"
else
  CONFIGURE_ARGS+= \
	--without-openssl
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_lighttpd-mod-webdav),)
  CONFIGURE_ARGS+= \
	--with-webdav-locks \
	--with-webdav-props
  # XXX: needed by sqlite3 to prevent segfaults in mod_webdav.so
  CONFIGURE_VARS+= \
	LIBS="-lpthread"
else
  CONFIGURE_ARGS+= \
	--without-webdav-locks \
	--without-webdav-props
endif

define Build/Configure
$(call Build/Configure/Default)
	# XXX: override pcre (mis)detection by ./configure when cross-compiling
	echo "#define HAVE_LIBPCRE 1" >>$(PKG_BUILD_DIR)/config.h
	echo "#define HAVE_PCRE_H 1" >>$(PKG_BUILD_DIR)/config.h
endef

define Package/lighttpd/conffiles
/etc/lighttpd/lighttpd.conf
endef

define Package/lighttpd/install
	$(INSTALL_DIR) $(1)/etc/lighttpd
	$(INSTALL_DATA) ./files/lighttpd.conf $(1)/etc/lighttpd/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/lighttpd.init $(1)/etc/init.d/lighttpd
	$(INSTALL_DIR) $(1)/usr/lib/lighttpd
	for m in dirlisting indexfile staticfile; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/lighttpd/mod_$$$${m}.so $(1)/usr/lib/lighttpd/ ; \
	done
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/lighttpd $(1)/usr/sbin/
endef

define BuildPlugin
  define Package/$(1)/install
	[ -z "$(2)" ] || $(INSTALL_DIR) $$(1)/usr/lib/lighttpd
	for m in $(2); do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/lighttpd/mod_$$$$$$$${m}.so $$(1)/usr/lib/lighttpd/ ; \
	done
  endef

  $$(eval $$(call BuildPackage,$(1)))
endef

$(eval $(call BuildPackage,lighttpd))
$(eval $(call BuildPlugin,lighttpd-mod-access,access))
$(eval $(call BuildPlugin,lighttpd-mod-accesslog,accesslog))
$(eval $(call BuildPlugin,lighttpd-mod-alias,alias))
$(eval $(call BuildPlugin,lighttpd-mod-auth,auth))
$(eval $(call BuildPlugin,lighttpd-mod-cgi,cgi))
$(eval $(call BuildPlugin,lighttpd-mod-cml,cml))
$(eval $(call BuildPlugin,lighttpd-mod-compress,compress))
$(eval $(call BuildPlugin,lighttpd-mod-evasive,evasive))
$(eval $(call BuildPlugin,lighttpd-mod-evhost,evhost))
$(eval $(call BuildPlugin,lighttpd-mod-expire,expire))
$(eval $(call BuildPlugin,lighttpd-mod-extforward,extforward))
$(eval $(call BuildPlugin,lighttpd-mod-fastcgi,fastcgi))
$(eval $(call BuildPlugin,lighttpd-mod-flv-streaming,flv_streaming))
$(eval $(call BuildPlugin,lighttpd-mod-magnet,magnet))
$(eval $(call BuildPlugin,lighttpd-mod-proxy,proxy))
$(eval $(call BuildPlugin,lighttpd-mod-redirect,redirect))
$(eval $(call BuildPlugin,lighttpd-mod-rewrite,rewrite))
$(eval $(call BuildPlugin,lighttpd-mod-rrdtool,rrdtool))
$(eval $(call BuildPlugin,lighttpd-mod-scgi,scgi))
$(eval $(call BuildPlugin,lighttpd-mod-secdownload,secdownload))
$(eval $(call BuildPlugin,lighttpd-mod-setenv,setenv))
$(eval $(call BuildPlugin,lighttpd-mod-simple-vhost,simple_vhost))
$(eval $(call BuildPlugin,lighttpd-mod-ssi,ssi))
$(eval $(call BuildPlugin,lighttpd-mod-status,status))
$(eval $(call BuildPlugin,lighttpd-mod-trigger-b4-dl,trigger_b4_dl))
$(eval $(call BuildPlugin,lighttpd-mod-userdir,userdir))
$(eval $(call BuildPlugin,lighttpd-mod-usertrack,usertrack))
$(eval $(call BuildPlugin,lighttpd-mod-webdav,webdav))
