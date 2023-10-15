#
# Copyright (C) 2006-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lighttpd
PKG_VERSION:=1.4.72
PKG_RELEASE:=1
# release candidate ~rcX testing; remove for release
#PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://download.lighttpd.net/lighttpd/releases-1.4.x
PKG_HASH:=f7cade4d69b754a0748c01463c33cd8b456ca9cc03bb09e85a71bcbcd54e55ec

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:lighttpd:lighttpd

# list config packages affecting MESON_ARGS
REBUILD_MODULES:= \
  authn_dbi \
  authn_gssapi \
  authn_ldap \
  authn_pam \
  authn_sasl \
  deflate \
  gnutls \
  magnet \
  maxminddb \
  mbedtls \
  nss \
  openssl \
  vhostdb_dbi \
  vhostdb_ldap \
  vhostdb_mysql \
  vhostdb_pgsql \
  webdav \
  wolfssl \

PKG_CONFIG_DEPENDS:= \
  $(patsubst %,CONFIG_PACKAGE_lighttpd-mod-%,$(REBUILD_MODULES)) \
  CONFIG_LIGHTTPD_PCRE2 \
  CONFIG_LIGHTTPD_CRYPTOLIB_NONE \
  CONFIG_LIGHTTPD_CRYPTOLIB_NETTLE \
  CONFIG_LIGHTTPD_CRYPTOLIB_MBEDTLS \
  CONFIG_LIGHTTPD_CRYPTOLIB_WOLFSSL

PKG_BUILD_DEPENDS:= \
  LIGHTTPD_PCRE2:pcre2 \
  LIGHTTPD_CRYPTOLIB_NETTLE:nettle \
  LIGHTTPD_CRYPTOLIB_MBEDTLS:mbedtls \
  LIGHTTPD_CRYPTOLIB_WOLFSSL:wolfssl

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

# choose crypto lib for lighttpd to use for crypto algorithms
# (separate from lighttpd TLS modules, which are each standalone)
cryptolibdep= \
  +LIGHTTPD_CRYPTOLIB_NETTLE:libnettle \
  +LIGHTTPD_CRYPTOLIB_MBEDTLS:libmbedtls \
  +LIGHTTPD_CRYPTOLIB_WOLFSSL:libwolfssl
ifdef CONFIG_LIGHTTPD_CRYPTOLIB_MBEDTLS
  TARGET_CPPFLAGS += -DFORCE_MBEDTLS_CRYPTO
else ifdef CONFIG_LIGHTTPD_CRYPTOLIB_WOLFSSL
  TARGET_CPPFLAGS += -DFORCE_WOLFSSL_CRYPTO
endif

define Package/lighttpd/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=https://www.lighttpd.net/
endef

define Package/lighttpd
  $(call Package/lighttpd/Default)
  MENU:=1
  DEPENDS:=+libpthread +LIGHTTPD_LOGROTATE:logrotate \
           +LIGHTTPD_PCRE2:libpcre2 \
           $(cryptolibdep)
  TITLE:=A flexible and lightweight web server
endef

define Package/lighttpd/config
config LIGHTTPD_SSL
	bool "SSL support (recommended)"
	depends on PACKAGE_lighttpd
	default y
	help
	  Implements SSL support in lighttpd (using libopenssl). This
	  option is enabled by default for backwards compatibility.
          Select one TLS module below if you enable the SSL engine in
	  your lighttpd configuration file.
          (mod_gnutls, mod_mbedtls, mod_nss, mod_openssl, mod_wolfssl)

config LIGHTTPD_SSL_DEPENDS
        bool
        depends on LIGHTTPD_SSL
        default PACKAGE_lighttpd-mod-mbedtls || PACKAGE_lighttpd-mod-wolfssl || PACKAGE_lighttpd-mod-gnutls || PACKAGE_lighttpd-mod-nss

config LIGHTTPD_SSL_SELECT
        tristate
        depends on LIGHTTPD_SSL
        default m if !LIGHTTPD_SSL_DEPENDS
        select PACKAGE_lighttpd-mod-openssl

config LIGHTTPD_PCRE2
	bool "PCRE2 support (recommended)"
	depends on PACKAGE_lighttpd
	default y
	help
	  PCRE2 regular expressions for lighttpd.conf conditions

if PACKAGE_lighttpd
	choice
		prompt "crypto library"
		default LIGHTTPD_CRYPTOLIB_MBEDTLS
		help
		  library to use for cryptographic algorithms

		config LIGHTTPD_CRYPTOLIB_NONE
			bool "None"

		config LIGHTTPD_CRYPTOLIB_NETTLE
			bool "libnettle"

		config LIGHTTPD_CRYPTOLIB_MBEDTLS
			bool "libmbedtls"

		config LIGHTTPD_CRYPTOLIB_WOLFSSL
			bool "libwolfssl"
	endchoice
endif

config LIGHTTPD_LOGROTATE
	bool "Logrotate support"
	depends on PACKAGE_lighttpd
	default n
	help
	  It adds support for logrotate functionality.
endef

MESON_ARGS += \
	-Dwith_brotli=disabled \
	-Dwith_bzip=disabled \
	-Dwith_dbi=$(if $(CONFIG_PACKAGE_lighttpd-mod-authn_dbi)$(CONFIG_PACKAGE_lighttpd-mod-vhostdb_dbi),enabled,disabled) \
	-Dwith_fam=disabled \
	-Dwith_gnutls=$(if $(CONFIG_PACKAGE_lighttpd-mod-gnutls),true,false) \
	-Dwith_krb5=$(if $(CONFIG_PACKAGE_lighttpd-mod-authn_gssapi),enabled,disabled) \
	-Dwith_ldap=$(if $(CONFIG_PACKAGE_lighttpd-mod-authn_ldap)$(CONFIG_PACKAGE_lighttpd-mod-vhostdb_ldap),enabled,disabled) \
	-Dwith_libunwind=disabled \
	-Dwith_lua=$(if $(CONFIG_PACKAGE_lighttpd-mod-magnet),true,false) \
	-Dlua_version=lua \
	-Dwith_maxminddb=$(if $(CONFIG_PACKAGE_lighttpd-mod-maxminddb),enabled,disabled) \
	-Dwith_mbedtls=$(if $(CONFIG_PACKAGE_lighttpd-mod-mbedtls),true,false) \
	-Dwith_mysql=$(if $(CONFIG_PACKAGE_lighttpd-mod-vhostdb_mysql),enabled,disabled) \
	-Dwith_nettle=$(if $(CONFIG_LIGHTTPD_CRYPTOLIB_NETTLE),true,false) \
	-Dwith_nss=$(if $(CONFIG_PACKAGE_lighttpd-mod-nss),true,false) \
	-Dwith_openssl=$(if $(CONFIG_PACKAGE_lighttpd-mod-openssl),true,false) \
	-Dwith_pam=$(if $(CONFIG_PACKAGE_lighttpd-mod-authn_pam),enabled,disabled) \
	-Dwith_pcre2=$(if $(CONFIG_LIGHTTPD_PCRE2),true,false) \
	-Dwith_pgsql=$(if $(CONFIG_PACKAGE_lighttpd-mod-vhostdb_pgsql),enabled,disabled) \
	-Dwith_sasl=$(if $(CONFIG_PACKAGE_lighttpd-mod-authn_sasl),enabled,disabled) \
	-Dwith_webdav_locks=$(if $(CONFIG_PACKAGE_lighttpd-mod-webdav),enabled,disabled) \
	-Dwith_webdav_props=$(if $(CONFIG_PACKAGE_lighttpd-mod-webdav),enabled,disabled) \
	-Dwith_wolfssl=$(if $(CONFIG_PACKAGE_lighttpd-mod-wolfssl),true,false) \
	-Dwith_xattr=false \
	-Dwith_zlib=$(if $(CONFIG_PACKAGE_lighttpd-mod-deflate),enabled,disabled) \
	-Dwith_zstd=disabled

BASE_MODULES:=dirlisting h2

define Package/lighttpd/conffiles
/etc/lighttpd/lighttpd.conf
endef

define Package/lighttpd/install
	$(INSTALL_DIR) $(1)/etc/lighttpd
	$(INSTALL_DATA) ./files/lighttpd.conf $(1)/etc/lighttpd/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/doc/config/conf.d/mime.conf $(1)/etc/lighttpd/
	$(INSTALL_DIR) $(1)/etc/lighttpd/conf.d
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/lighttpd.init $(1)/etc/init.d/lighttpd
	$(INSTALL_DIR) $(1)/usr/lib/lighttpd
	for m in $(BASE_MODULES); do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/lighttpd/mod_$$$${m}.so $(1)/usr/lib/lighttpd/ ; \
	done
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/lighttpd $(1)/usr/sbin/

ifneq ($(strip $(CONFIG_LIGHTTPD_LOGROTATE)),)
	$(INSTALL_DIR) $(1)/etc/logrotate.d
	$(CP) ./files/lighttpd.logrotate $(1)/etc/logrotate.d/lighttpd.conf
endif
endef

define BuildPlugin
  define Package/lighttpd-mod-$(1)
    $(call Package/lighttpd/Default)
    DEPENDS:=lighttpd
    ifneq ($(3),)
      DEPENDS+= $(3)
    endif
    TITLE:=$(2) module
  endef

  define Package/lighttpd-mod-$(1)/conffiles
/etc/lighttpd/conf.d/$(4)-$(1).conf
  endef

 ifneq ($(SDK)$(CONFIG_PACKAGE_lighttpd-mod-$(1)),)
  define Package/lighttpd-mod-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/lib/lighttpd
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lighttpd/mod_$(1).so $$(1)/usr/lib/lighttpd
	$(INSTALL_DIR) $$(1)/etc/lighttpd/conf.d
	if [ -f $(PKG_BUILD_DIR)/doc/config/conf.d/$(1).conf ]; then \
		$(CP) $(PKG_BUILD_DIR)/doc/config/conf.d/$(1).conf $$(1)/etc/lighttpd/conf.d/$(4)-$(1).conf ; \
		if ! grep -qF 'mod_$(1)' $$(1)/etc/lighttpd/conf.d/$(4)-$(1).conf; then \
			sed -i "`sed '/^##/ !q' $$(1)/etc/lighttpd/conf.d/$(4)-$(1).conf | wc -l` i\
server.modules += ( \"mod_$(1)\" )" $$(1)/etc/lighttpd/conf.d/$(4)-$(1).conf ; \
		fi \
	else \
		echo 'server.modules += ( "mod_$(1)" )' > $$(1)/etc/lighttpd/conf.d/$(4)-$(1).conf ; \
	fi
  endef
 endif

  $$(eval $$(call BuildPackage,lighttpd-mod-$(1)))
endef

$(eval $(call BuildPackage,lighttpd))

$(eval $(call BuildPlugin,auth,Authentication,$(cryptolibdep),20))
$(eval $(call BuildPlugin,authn_dbi,DBI-based authentication,lighttpd-mod-auth libdbi $(cryptolibdep),20))
$(eval $(call BuildPlugin,authn_file,File-based authentication,lighttpd-mod-auth $(cryptolibdep),20))
$(eval $(call BuildPlugin,authn_gssapi,Kerberos-based authentication,lighttpd-mod-auth krb5-libs $(cryptolibdep),20))
$(eval $(call BuildPlugin,authn_ldap,LDAP-based authentication,lighttpd-mod-auth libopenldap,20))
$(eval $(call BuildPlugin,authn_pam,PAM-based authentication,lighttpd-mod-auth libpam,20))
$(eval $(call BuildPlugin,authn_sasl,SASL-based authentication,lighttpd-mod-auth libsasl2,20))

$(eval $(call BuildPlugin,accesslog,Access logging,,30))
$(eval $(call BuildPlugin,ajp13,AJP13 Tomcat connector,,30))
$(eval $(call BuildPlugin,cgi,CGI,,30))
$(eval $(call BuildPlugin,deflate,Compress dynamic output,+PACKAGE_lighttpd-mod-deflate:zlib,30))
$(eval $(call BuildPlugin,extforward,Extract client,,30))
$(eval $(call BuildPlugin,gnutls,TLS using gnutls,@LIGHTTPD_SSL +PACKAGE_lighttpd-mod-gnutls:libgnutls,30))
$(eval $(call BuildPlugin,magnet,Magnet,+PACKAGE_lighttpd-mod-magnet:liblua,30))
$(eval $(call BuildPlugin,maxminddb,MaxMind DB,+PACKAGE_lighttpd-mod-maxminddb:libmaxminddb,30))
$(eval $(call BuildPlugin,mbedtls,TLS using mbedtls,@LIGHTTPD_SSL +PACKAGE_lighttpd-mod-mbedtls:libmbedtls,30))
$(eval $(call BuildPlugin,nss,TLS using nss,@LIGHTTPD_SSL +PACKAGE_lighttpd-mod-nss:libnss,30))
$(eval $(call BuildPlugin,openssl,TLS using openssl,@LIGHTTPD_SSL +PACKAGE_lighttpd-mod-openssl:libopenssl,30))
$(eval $(call BuildPlugin,proxy,Proxy,,30))
$(eval $(call BuildPlugin,rrdtool,RRDtool,rrdtool1,30))
$(eval $(call BuildPlugin,sockproxy,sockproxy,,30))
$(eval $(call BuildPlugin,ssi,SSI,,30))
$(eval $(call BuildPlugin,status,Server status display,,30))
$(eval $(call BuildPlugin,userdir,User directory,,30))
$(eval $(call BuildPlugin,vhostdb,Virtual Host Database,,30))
$(eval $(call BuildPlugin,vhostdb_dbi,Virtual Host Database (DBI),lighttpd-mod-vhostdb +PACKAGE_lighttpd-mod-vhostdb_dbi:libdbi,30))
$(eval $(call BuildPlugin,vhostdb_ldap,Virtual Host Database (LDAP),lighttpd-mod-vhostdb +PACKAGE_lighttpd-mod-vhostdb_ldap:libopenldap,30))
$(eval $(call BuildPlugin,vhostdb_mysql,Virtual Host Database (MariaDB),lighttpd-mod-vhostdb +PACKAGE_lighttpd-mod-vhostdb_mysql:libmariadb,30))
$(eval $(call BuildPlugin,vhostdb_pgsql,Virtual Host Database (PostgreSQL),lighttpd-mod-vhostdb +PACKAGE_lighttpd-mod-vhostdb_pgsql:libpq,30))
$(eval $(call BuildPlugin,webdav,WebDAV,+PACKAGE_lighttpd-mod-webdav:libsqlite3 +PACKAGE_lighttpd-mod-webdav:libuuid +PACKAGE_lighttpd-mod-webdav:libxml2,30))
$(eval $(call BuildPlugin,webdav_min,WebDAV,,30))
$(eval $(call BuildPlugin,wolfssl,TLS using wolfssl,@LIGHTTPD_SSL +PACKAGE_lighttpd-mod-wolfssl:libwolfssl,30))
$(eval $(call BuildPlugin,wstunnel,Websocket tunneling,$(cryptolibdep),30))

# (similar to BuildPlugin, but without associated .so)
define BuiltinPlugin
  define Package/lighttpd-mod-$(1)
    $(call Package/lighttpd/Default)
    DEPENDS:=lighttpd
    ifneq ($(3),)
      DEPENDS+= $(3)
    endif
    TITLE:=$(2) module
  endef

  define Package/lighttpd-mod-$(1)/conffiles
/etc/lighttpd/conf.d/$(4)-$(1).conf
  endef

 ifneq ($(SDK)$(CONFIG_PACKAGE_lighttpd-mod-$(1)),)
  define Package/lighttpd-mod-$(1)/install
	$(INSTALL_DIR) $$(1)/etc/lighttpd/conf.d
	if [ -f $(PKG_BUILD_DIR)/doc/config/conf.d/$(1).conf ]; then \
		$(CP) $(PKG_BUILD_DIR)/doc/config/conf.d/$(1).conf $$(1)/etc/lighttpd/conf.d/$(4)-$(1).conf ; \
		if ! grep -qF 'mod_$(1)' $$(1)/etc/lighttpd/conf.d/$(4)-$(1).conf; then \
			sed -i "`sed '/^##/ !q' $$(1)/etc/lighttpd/conf.d/$(4)-$(1).conf | wc -l` i\
server.modules += ( \"mod_$(1)\" )" $$(1)/etc/lighttpd/conf.d/$(4)-$(1).conf ; \
		fi \
	else \
		echo 'server.modules += ( "mod_$(1)" )' > $$(1)/etc/lighttpd/conf.d/$(4)-$(1).conf ; \
	fi
  endef
 endif

  $$(eval $$(call BuildPackage,lighttpd-mod-$(1)))
endef

# included in BASE_MODULES:=dirlisting h2
#$(eval $(call BuildPlugin,dirlisting,dirlisting,,30))
#$(eval $(call BuildPlugin,h2,HTTP/2,,30))

# included in base lighttpd executable;
# no longer loaded as separate dynamic modules
# no longer in BASE_MODULES
#$(eval $(call BuiltinPlugin,indexfile,indexfile,,30))
#$(eval $(call BuiltinPlugin,staticfile,staticfile,,30))

# included in base lighttpd executable;
# no longer loaded as separate dynamic modules
# though still need to be enabled in config
$(eval $(call BuiltinPlugin,access,Access restrictions,,30))
$(eval $(call BuiltinPlugin,alias,Directory alias,,30))
$(eval $(call BuiltinPlugin,evhost,Enhanced Virtual-Hosting,,30))
$(eval $(call BuiltinPlugin,expire,Expire,,30))
$(eval $(call BuiltinPlugin,fastcgi,FastCGI,,30))
$(eval $(call BuiltinPlugin,redirect,URL redirection,+LIGHTTPD_PCRE2:libpcre2,10))
$(eval $(call BuiltinPlugin,rewrite,URL rewriting,+LIGHTTPD_PCRE2:libpcre2,30))
$(eval $(call BuiltinPlugin,scgi,SCGI,,30))
$(eval $(call BuiltinPlugin,setenv,Environment variable setting,,30))
$(eval $(call BuiltinPlugin,simple_vhost,Simple virtual hosting,,30))
