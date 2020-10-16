#
# Copyright (C) 2006-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lighttpd
PKG_VERSION:=1.4.55
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://download.lighttpd.net/lighttpd/releases-1.4.x
PKG_HASH:=6a0b50e9c9d5cc3d9e48592315c25a2d645858f863e1ccd120507a30ce21e927

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:lighttpd:lighttpd

PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=meson/host
PKG_CONFIG_DEPENDS:=CONFIG_LIGHTTPD_SSL $(patsubst %,CONFIG_PACKAGE_lighttpd-mod-%,$(REBUILD_MODULES))

REBUILD_MODULES=authn_gssapi authn_ldap authn_mysql cml magnet mysql_vhost trigger_b4_dl webdav

include $(INCLUDE_DIR)/package.mk
# iconv is required for lighttpd's mysql plugin
include $(INCLUDE_DIR)/nls.mk
include ../../devel/meson/meson.mk

define Package/lighttpd/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=https://www.lighttpd.net/
endef

define Package/lighttpd
  $(call Package/lighttpd/Default)
  MENU:=1
  DEPENDS:=+LIGHTTPD_SSL:libopenssl +libpcre +libpthread +LIGHTTPD_LOGROTATE:logrotate
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

config LIGHTTPD_LOGROTATE
	bool "Logrotate support"
	depends on PACKAGE_lighttpd
	default n
	help
	  It adds support for logrotate functionality.
endef

MESON_ARGS += \
	-Dwith_bzip=false \
	-Dwith_dbi=$(if $(CONFIG_PACKAGE_lighttpd-mod-vhostdb_dbi),true,false) \
	-Dwith_fam=false \
	-Dwith_gdbm=$(if $(CONFIG_PACKAGE_lighttpd-mod-trigger_b4_dl),true,false) \
	-Dwith_geoip=$(if $(CONFIG_PACKAGE_lighttpd-mod-geoip),true,false) \
	-Dwith_krb5=$(if $(CONFIG_PACKAGE_lighttpd-mod-authn_gssapi),true,false) \
	-Dwith_ldap=$(if $(CONFIG_PACKAGE_lighttpd-mod-authn_ldap)$(CONFIG_PACKAGE_lighttpd-mod-vhostdb_ldap),true,false) \
	-Dwith_libev=false \
	-Dwith_libunwind=false \
	-Dwith_lua=$(if $(CONFIG_PACKAGE_lighttpd-mod-cml)$(CONFIG_PACKAGE_lighttpd-mod-magnet),true,false) \
	-Dwith_maxminddb=$(if $(CONFIG_PACKAGE_lighttpd-mod-maxminddb),true,false) \
	-Dwith_memcached=false \
	-Dwith_mysql=$(if $(CONFIG_PACKAGE_lighttpd-mod-authn_mysql)$(CONFIG_PACKAGE_lighttpd-mod-mysql_vhost)$(CONFIG_PACKAGE_lighttpd-mod-vhostdb_mysql),true,false) \
	-Dwith_openssl=$(if $(CONFIG_LIGHTTPD_SSL),true,false) \
	-Dwith_pam=$(if $(CONFIG_PACKAGE_lighttpd-mod-authn_pam),true,false) \
	-Dwith_pcre=true \
	-Dwith_pgsql=$(if $(CONFIG_PACKAGE_lighttpd-mod-vhostdb_pgsql),true,false) \
	-Dwith_sasl=$(if $(CONFIG_PACKAGE_lighttpd-mod-authn_sasl),true,false) \
	-Dwith_webdav_locks=$(if $(CONFIG_PACKAGE_lighttpd-mod-webdav),true,false) \
	-Dwith_webdav_props=$(if $(CONFIG_PACKAGE_lighttpd-mod-webdav),true,false) \
	-Dwith_wolfssl=false \
	-Dwith_xattr=false \
	-Dwith_zlib=$(if $(CONFIG_PACKAGE_lighttpd-mod-compress)$(CONFIG_PACKAGE_lighttpd-mod-deflate),true,false)

BASE_MODULES:=dirlisting indexfile staticfile

ifneq ($(strip $(CONFIG_LIGHTTPD_SSL)),)
  BASE_MODULES+= openssl
endif

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

# First, permit redirect from HTTP to HTTPS.
$(eval $(call BuildPlugin,redirect,URL redirection,+PACKAGE_lighttpd-mod-redirect:libpcre,10))

# Next, permit authentication.
$(eval $(call BuildPlugin,auth,Authentication,+PACKAGE_lighttpd-mod-auth:lighttpd-mod-authn_file,20))
$(eval $(call BuildPlugin,authn_file,File-based authentication,,20))
$(eval $(call BuildPlugin,authn_gssapi,Kerberos-based authentication,lighttpd-mod-auth +PACKAGE_lighttpd-mod-authn_gssapi:krb5-libs,20))
$(eval $(call BuildPlugin,authn_ldap,LDAP-based authentication,lighttpd-mod-auth +PACKAGE_lighttpd-mod-authn_ldap:libopenldap,20))
$(eval $(call BuildPlugin,authn_mysql,Mysql-based authentication,lighttpd-mod-auth +PACKAGE_lighttpd-mod-authn_mysql:libmysqlclient,20))
$(eval $(call BuildPlugin,authn_pam,PAM-based authentication,lighttpd-mod-auth +PACKAGE_lighttpd-mod-authn_pam:libpam,20))
$(eval $(call BuildPlugin,authn_sasl,SASL-based authentication,lighttpd-mod-auth +PACKAGE_lighttpd-mod-authn_sasl:libsasl2,20))

# Finally, everything else.
$(eval $(call BuildPlugin,access,Access restrictions,,30))
$(eval $(call BuildPlugin,accesslog,Access logging,,30))
$(eval $(call BuildPlugin,alias,Directory alias,,30))
$(eval $(call BuildPlugin,cgi,CGI,,30))
#$(eval $(call BuildPlugin,cml,Cache Meta Language,+PACKAGE_lighttpd-mod-cml:liblua +PACKAGE_lighttpd-mod-cml:libmemcached,30))
$(eval $(call BuildPlugin,cml,Cache Meta Language,+PACKAGE_lighttpd-mod-cml:liblua,30))
$(eval $(call BuildPlugin,compress,Compress output,+PACKAGE_lighttpd-mod-compress:zlib,30))
$(eval $(call BuildPlugin,deflate,Compress dynamic output,+PACKAGE_lighttpd-mod-deflate:zlib,30))
$(eval $(call BuildPlugin,evasive,Evasive,,30))
$(eval $(call BuildPlugin,evhost,Enhanced Virtual-Hosting,,30))
$(eval $(call BuildPlugin,expire,Expire,,30))
$(eval $(call BuildPlugin,extforward,Extract client,,30))
$(eval $(call BuildPlugin,fastcgi,FastCGI,,30))
$(eval $(call BuildPlugin,flv_streaming,FLV streaming,,30))
#$(eval $(call BuildPlugin,geoip,Geolocation,+PACKAGE_lighttpd-mod-geoip:libgeoip,30)) #libgeoip is not in OpenWrt
$(eval $(call BuildPlugin,magnet,Magnet,+PACKAGE_lighttpd-mod-magnet:liblua,30))
$(eval $(call BuildPlugin,maxminddb,MaxMind DB,+PACKAGE_lighttpd-mod-maxminddb:libmaxminddb,30))
$(eval $(call BuildPlugin,mysql_vhost,Mysql virtual hosting,+PACKAGE_lighttpd-mod-mysql_vhost:libmysqlclient,30))
$(eval $(call BuildPlugin,proxy,Proxy,,30))
$(eval $(call BuildPlugin,rewrite,URL rewriting,+PACKAGE_lighttpd-mod-rewrite:libpcre,30))
$(eval $(call BuildPlugin,rrdtool,RRDtool,,30))
$(eval $(call BuildPlugin,scgi,SCGI,,30))
$(eval $(call BuildPlugin,secdownload,Secure and fast download,,30))
$(eval $(call BuildPlugin,setenv,Environment variable setting,,30))
$(eval $(call BuildPlugin,simple_vhost,Simple virtual hosting,,30))
$(eval $(call BuildPlugin,sockproxy,sockproxy,,30))
$(eval $(call BuildPlugin,ssi,SSI,+PACKAGE_lighttpd-mod-ssi:libpcre,30))
$(eval $(call BuildPlugin,staticfile,staticfile,,30))
$(eval $(call BuildPlugin,status,Server status display,,30))
#$(eval $(call BuildPlugin,trigger_b4_dl,Trigger before download,+PACKAGE_lighttpd-mod-trigger_b4_dl:libpcre +PACKAGE_lighttpd-mod-trigger_b4_dl:libgdbm +PACKAGE_lighttpd-mod-trigger_b4_dl:libmemcached,30))
$(eval $(call BuildPlugin,trigger_b4_dl,Trigger before download,+PACKAGE_lighttpd-mod-trigger_b4_dl:libpcre +PACKAGE_lighttpd-mod-trigger_b4_dl:libgdbm,30))
$(eval $(call BuildPlugin,uploadprogress,Upload Progress,,30))
$(eval $(call BuildPlugin,userdir,User directory,,30))
$(eval $(call BuildPlugin,usertrack,User tracking,,30))
$(eval $(call BuildPlugin,vhostdb_dbi,Virtual Host Database (DBI),+PACKAGE_lighttpd-mod-vhostdb_dbi:libdbi,30))
$(eval $(call BuildPlugin,vhostdb_ldap,Virtual Host Database (LDAP),+PACKAGE_lighttpd-mod-vhostdb_ldap:libopenldap,30))
$(eval $(call BuildPlugin,vhostdb_mysql,Virtual Host Database (MariaDB),+PACKAGE_lighttpd-mod-vhostdb_mysql:libmysqlclient,30))
$(eval $(call BuildPlugin,vhostdb_pgsql,Virtual Host Database (PostgreSQL),+PACKAGE_lighttpd-mod-vhostdb_pgsql:libpq,30))
$(eval $(call BuildPlugin,vhostdb,Virtual Host Database,,30))
$(eval $(call BuildPlugin,webdav,WebDAV,+PACKAGE_lighttpd-mod-webdav:libsqlite3 +PACKAGE_lighttpd-mod-webdav:libuuid +PACKAGE_lighttpd-mod-webdav:libxml2,30))
$(eval $(call BuildPlugin,wstunnel,Websocket tunneling,,30))
