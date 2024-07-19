#
# Copyright (C) 2008-2020 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=freeradius3
PKG_VERSION:=3.2.5
PKG_RELEASE:=1

PKG_SOURCE:=freeradius-server-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://freeradius.org/ftp/pub/freeradius
PKG_HASH:=1e75f5fc1961d9854d1cb3c6921612fbe2b9edb8ee508a5a7cbd69f1e7607115

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYRIGHT LICENSE
PKG_CPE_ID:=cpe:/a:freeradius:freeradius

PKG_BUILD_DIR:=$(BUILD_DIR)/freeradius-server-$(PKG_VERSION)
PKG_FIXUP:=autoreconf
PYTHON3_PKG_BUILD:=0

PKG_CONFIG_DEPENDS := \
  FREERADIUS3_OPENSSL \
  FREERADIUS3_NOSSL

CFLAGS += $(FPIC)

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/freeradius3/config
  source "$(SOURCE)/Config.in"
endef

define Package/freeradius3/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://freeradius.org/
  SUBMENU:=FreeRADIUS (version 3)
endef

define Package/freeradius3
  $(call Package/freeradius3/Default)
  DEPENDS:=+freeradius3-common
  TITLE:=A flexible RADIUS server (version 3)
endef

define Package/freeradius3/conffiles
/etc/freeradius3/clients.conf
/etc/freeradius3/policy.d/accounting
/etc/freeradius3/policy.d/filter
/etc/freeradius3/proxy.conf
/etc/freeradius3/radiusd.conf
/etc/freeradius3/sites-available/default
/etc/freeradius3/sites-enabled/default
endef

define Package/freeradius3-common
  $(call Package/freeradius3/Default)
  TITLE:=common files
  DEPENDS:=+USE_GLIBC:libpthread +USE_GLIBC:libbsd +FREERADIUS3_OPENSSL:libopenssl +libcap +libpcap +libncurses +libreadline +libtalloc +libatomic
endef

define Package/freeradius3-default
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 \
+freeradius3-democerts \
+freeradius3-mod-always \
+freeradius3-mod-attr-filter \
+freeradius3-mod-chap \
+freeradius3-mod-detail \
+freeradius3-mod-digest \
+freeradius3-mod-eap \
+freeradius3-mod-eap-gtc \
+freeradius3-mod-eap-md5 \
+freeradius3-mod-eap-mschapv2 \
+freeradius3-mod-eap-peap \
+freeradius3-mod-eap-pwd \
+freeradius3-mod-eap-tls \
+freeradius3-mod-eap-ttls \
+freeradius3-mod-exec \
+freeradius3-mod-expiration \
+freeradius3-mod-expr \
+freeradius3-mod-files \
+freeradius3-mod-logintime \
+freeradius3-mod-mschap \
+freeradius3-mod-pap \
+freeradius3-mod-preprocess \
+freeradius3-mod-radutmp \
+freeradius3-mod-realm \
+freeradius3-mod-unix
  TITLE:=Modules needed for Radius default configuration
endef

define Package/freeradius3-default/description
 This meta-package contains only dependencies for modules needed in
 FreeRADIUS default configuration.
endef

define Package/freeradius3-democerts
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Demo certificates to test the server
endef

define Package/freeradius3-mod-always
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Always module
endef

define Package/freeradius3-mod-always/conffiles
/etc/freeradius3/mods-available/always
/etc/freeradius3/mods-enabled/always
endef

define Package/freeradius3-mod-attr-filter
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=ATTR filter module
endef

define Package/freeradius3-mod-attr-filter/conffiles
/etc/freeradius3/mods-available/attr_filter
/etc/freeradius3/mods-enabled/attr_filter
/etc/freeradius3/mods-config/attr_filter/access_challenge
/etc/freeradius3/mods-config/attr_filter/access_reject
/etc/freeradius3/mods-config/attr_filter/accounting_response
/etc/freeradius3/mods-config/attr_filter/coa
/etc/freeradius3/mods-config/attr_filter/post-proxy
/etc/freeradius3/mods-config/attr_filter/pre-proxy
endef

define Package/freeradius3-mod-cache
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=DATASTORE CACHE
endef

define Package/freeradius3-mod-cache/conffiles
/etc/freeradius3/mods-available/cache
endef

define Package/freeradius3-mod-cache-rbtree
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 +freeradius3-mod-cache
  TITLE:=DATASTORE CACHE RBTREE
endef

define Package/freeradius3-mod-cache-redis
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 +freeradius3-mod-cache +libhiredis
  TITLE:=DATASTORE CACHE REDIS
endef

define Package/freeradius3-mod-chap
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=CHAP module
endef

define Package/freeradius3-mod-chap/conffiles
/etc/freeradius3/mods-available/chap
/etc/freeradius3/mods-enabled/chap
endef

define Package/freeradius3-mod-counter
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 +libgdbm
  TITLE:=Module counter
endef

define Package/freeradius3-mod-counter/conffiles
/etc/freeradius3/mods-available/counter
endef

define Package/freeradius3-mod-date
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Module date
endef

define Package/freeradius3-mod-date/conffiles
/etc/freeradius3/mods-available/date
endef

define Package/freeradius3-mod-detail
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Detailed accounting module
endef

define Package/freeradius3-mod-detail/conffiles
/etc/freeradius3/mods-available/detail
/etc/freeradius3/mods-enabled/detail
endef

define Package/freeradius3-mod-digest
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=HTTP Digest Authentication
endef

define Package/freeradius3-mod-digest/conffiles
/etc/freeradius3/mods-available/digest
/etc/freeradius3/mods-enabled/digest
endef

define Package/freeradius3-mod-dpsk
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=MODULE DPSK
endef

define Package/freeradius3-mod-dpsk/conffiles
/etc/freeradius3/mods-available/dpsk
endef

define Package/freeradius3-mod-dynamic-clients
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Dynamic Clients Authentication
endef

define Package/freeradius3-mod-dynamic-clients/conffiles
/etc/freeradius3/mods-available/dynamic_clients
/etc/freeradius3/sites-available/dynamic-clients
endef

define Package/freeradius3-mod-eap
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Base EAP module
endef

define Package/freeradius3-mod-eap/conffiles
/etc/freeradius3/mods-available/eap
/etc/freeradius3/mods-enabled/eap
/etc/freeradius3/policy.d/eap
/etc/freeradius3/sites-enabled/inner-tunnel
/etc/freeradius3/sites-available/inner-tunnel
endef

define Package/freeradius3-mod-eap-fast
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-eap @FREERADIUS3_OPENSSL
  TITLE:=EAP/FAST module
endef

define Package/freeradius3-mod-eap-gtc
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-eap
  TITLE:=EAP/GTC module
endef

define Package/freeradius3-mod-eap-md5
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-eap
  TITLE:=EAP/MD5 module
endef

define Package/freeradius3-mod-eap-mschapv2
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-eap +freeradius3-mod-mschap
  TITLE:=EAP/MS-CHAPv2 module
endef

define Package/freeradius3-mod-eap-peap
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-eap @FREERADIUS3_OPENSSL
  TITLE:=EAP/PEAP module
endef

define Package/freeradius3-mod-eap-pwd
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-eap @FREERADIUS3_OPENSSL
  TITLE:=EAP/PWD module
endef

define Package/freeradius3-mod-eap-sim
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-eap
  TITLE:=EAP/SIM module
endef

define Package/freeradius3-mod-eap-tls
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-eap @FREERADIUS3_OPENSSL
  TITLE:=EAP/TLS module
endef

define Package/freeradius3-mod-eap-ttls
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-eap-tls
  TITLE:=EAP/TTLS module
endef

define Package/freeradius3-mod-exec
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=EXEC module
endef

define Package/freeradius3-mod-exec/conffiles
/etc/freeradius3/mods-available/exec
/etc/freeradius3/mods-enabled/exec
endef

define Package/freeradius3-mod-expiration
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Expiration module
endef

define Package/freeradius3-mod-expiration/conffiles
/etc/freeradius3/mods-available/expiration
/etc/freeradius3/mods-enabled/expiration
endef

define Package/freeradius3-mod-expr
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=EXPR module
endef

define Package/freeradius3-mod-expr/conffiles
/etc/freeradius3/mods-available/expr
/etc/freeradius3/mods-enabled/expr
endef

define Package/freeradius3-mod-files
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Module using local files for authorization
endef

define Package/freeradius3-mod-files/conffiles
/etc/freeradius3/mods-available/files
/etc/freeradius3/mods-enabled/files
/etc/freeradius3/mods-config/files/accounting
/etc/freeradius3/mods-config/files/authorize
/etc/freeradius3/mods-config/files/pre-proxy
endef

define Package/freeradius3-mod-ippool
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 +libgdbm
  TITLE:=Radius IP Pool module
endef

define Package/freeradius3-mod-ippool/conffiles
/etc/freeradius3/mods-available/ippool
endef

define Package/freeradius3-mod-json
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 +libjson-c
  TITLE:=Json module
endef

define Package/freeradius3-mod-json/conffiles
/etc/freeradius3/mods-available/json
endef

define Package/freeradius3-mod-krb5
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 +krb5-libs
  TITLE:=Krb5 module
endef

define Package/freeradius3-mod-krb5/conffiles
/etc/freeradius3/mods-available/krb5
endef

define Package/freeradius3-mod-ldap
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 +libopenldap @FREERADIUS3_OPENSSL
  TITLE:=LDAP Authentication
endef

define Package/freeradius3-mod-ldap/conffiles
/etc/freeradius3/mods-available/ldap
endef

define Package/freeradius3-mod-linelog
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Linelog module
endef

define Package/freeradius3-mod-linelog/conffiles
/etc/freeradius3/mods-available/linelog
endef

define Package/freeradius3-mod-logintime
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Logintime module
endef

define Package/freeradius3-mod-logintime/conffiles
/etc/freeradius3/mods-available/logintime
/etc/freeradius3/mods-enabled/logintime
endef

define Package/freeradius3-mod-mschap
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=MS-CHAP and MS-CHAPv2 module
endef

define Package/freeradius3-mod-mschap/conffiles
/etc/freeradius3/mods-available/mschap
/etc/freeradius3/mods-enabled/mschap
endef

define Package/freeradius3-mod-pam
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 +libpam
  TITLE:=PAM module
endef

define Package/freeradius3-mod-pam/conffiles
/etc/freeradius3/mods-available/pam
endef

define Package/freeradius3-mod-pap
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=PAP module
endef

define Package/freeradius3-mod-pap/conffiles
/etc/freeradius3/mods-available/pap
/etc/freeradius3/mods-enabled/pap
endef

define Package/freeradius3-mod-passwd
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Rlm passwd module
endef

define Package/freeradius3-mod-passwd/conffiles
/etc/freeradius3/mods-available/passwd
/etc/freeradius3/mods-enabled/passwd
endef

define Package/freeradius3-mod-preprocess
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Request pre-processing module
endef

define Package/freeradius3-mod-preprocess/conffiles
/etc/freeradius3/mods-config/preprocess/hints
/etc/freeradius3/mods-config/preprocess/huntgroups
/etc/freeradius3/mods-available/preprocess
/etc/freeradius3/mods-enabled/preprocess
endef

define Package/freeradius3-mod-python3
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 +python3
  TITLE:=Python3 module
endef

define Package/freeradius3-mod-python3/conffiles
/etc/freeradius3/mods-available/python3
endef

define Package/freeradius3-mod-radutmp
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Radius UTMP module
endef

define Package/freeradius3-mod-radutmp/conffiles
/etc/freeradius3/mods-available/radutmp
/etc/freeradius3/mods-enabled/radutmp
/etc/freeradius3/mods-available/sradutmp
/etc/freeradius3/mods-enabled/sradutmp
endef

define Package/freeradius3-mod-realm
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Realms handling module
endef

define Package/freeradius3-mod-realm/conffiles
/etc/freeradius3/mods-available/realm
/etc/freeradius3/mods-enabled/realm
endef

define Package/freeradius3-mod-redis
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 +libhiredis
  TITLE:=Redis module
endef

define Package/freeradius3-mod-redis/conffiles
/etc/freeradius3/mods-available/redis
endef

define Package/freeradius3-mod-rediswho
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 freeradius3-mod-redis
  TITLE:=Rediswho module
endef

define Package/freeradius3-mod-rediswho/conffiles
/etc/freeradius3/mods-available/rediswho
endef

define Package/freeradius3-mod-replicate
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Replicate module
endef

define Package/freeradius3-mod-replicate/conffiles
/etc/freeradius3/mods-available/replicate
endef

define Package/freeradius3-mod-rest
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 +libcurl +libjson-c
  TITLE:=Radius REST module
endef

define Package/freeradius3-mod-rest/conffiles
/etc/freeradius3/mods-available/rest
endef

define Package/freeradius3-mod-soh
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=SoH module
endef

define Package/freeradius3-mod-soh/conffiles
/etc/freeradius3/mods-available/soh
/etc/freeradius3/sites-available/soh
endef

define Package/freeradius3-mod-sometimes
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Sometimes module
endef

define Package/freeradius3-mod-sometimes/conffiles
/etc/freeradius3/mods-available/sometimes
endef

define Package/freeradius3-mod-sql
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Radius generic SQL front-end
endef

define Package/freeradius3-mod-sql/conffiles
/etc/freeradius3/mods-available/sql
endef

define Package/freeradius3-mod-sql-map
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Map module
endef

define Package/freeradius3-mod-map/conffiles
/etc/freeradius3/mods-available/sql_map
endef

define Package/freeradius3-mod-sql-mysql
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-sql +libmysqlclient
  TITLE:=Radius MySQL back-end drivers
endef

define Package/freeradius3-mod-sql-mysql/conffiles
/etc/freeradius3/mods-config/sql/main/mysql
endef

define Package/freeradius3-mod-sql-null
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-sql
  TITLE:=Radius Dummy SQL back-end drivers
endef

define Package/freeradius3-mod-sql-postgresql
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-sql +libpq
  TITLE:=Radius PostgreSQL back-end drivers
endef

define Package/freeradius3-mod-sql-postgresql/conffiles
/etc/freeradius3/mods-config/sql/main/postgresql
endef

define Package/freeradius3-mod-sql-sqlite
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-sql +libsqlite3
  TITLE:=Radius SQLite back-end drivers
endef

define Package/freeradius3-mod-sql-sqlite/conffiles
/etc/freeradius3/mods-config/sql/main/sqlite
endef

define Package/freeradius3-mod-sql-unixodbc
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-sql +unixodbc
  TITLE:=Radius unixODBC back-end drivers
endef

define Package/freeradius3-mod-sqlcounter
  $(call Package/freeradius3/Default)
  DEPENDS:=+freeradius3-mod-sql
  TITLE:=Module sqlcounter
endef

define Package/freeradius3-mod-sqlcounter/conffiles
/etc/freeradius3/mods-config/sql/counter
/etc/freeradius3/mods-available/sqlcounter
endef

define Package/freeradius3-mod-sqlippool
  $(call Package/freeradius3/Default)
  DEPENDS:=+freeradius3-mod-sql
  TITLE:=Radius SQL Based IP Pool module
endef

define Package/freeradius3-mod-sqlippool/conffiles
/etc/freeradius3/mods-config/sql/ippool
/etc/freeradius3/mods-config/sql/ippool-dhcp
/etc/freeradius3/mods-available/dhcp_sqlippool
/etc/freeradius3/mods-available/sqlippool
endef

define Package/freeradius3-mod-totp
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Totp module
endef

define Package/freeradius3-mod-totp/conffiles
/etc/freeradius3/mods-available/totp
/etc/freeradius3/sites-available/totp
endef

define Package/freeradius3-mod-unbound
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 +libunbound
  TITLE:=Unbound module
endef

define Package/freeradius3-mod-unbound/conffiles
/etc/freeradius3/mods-available/unbound
/etc/freeradius3/mods-config/unbound
endef

define Package/freeradius3-mod-unix
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=System Authentication
endef

define Package/freeradius3-mod-unix/conffiles
/etc/freeradius3/mods-available/unix
/etc/freeradius3/mods-enabled/unix
endef

define Package/freeradius3-mod-unpack
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Unpack module
endef

define Package/freeradius3-mod-unpack/conffiles
/etc/freeradius3/mods-available/unpack
endef

define Package/freeradius3-mod-utf8
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=UTF8 module
endef

define Package/freeradius3-mod-utf8/conffiles
/etc/freeradius3/mods-available/utf8
endef

define Package/freeradius3-mod-wimax
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Wimax Authentication
endef

define Package/freeradius3-mod-wimax/conffiles
/etc/freeradius3/mods-available/wimax
endef

define Package/freeradius3-mod-yubikey
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3 +libyubikey +ykclient
  TITLE:=Yubikey Authentication
endef

define Package/freeradius3-mod-yubikey/conffiles
/etc/freeradius3/mods-available/yubikey
endef

define Package/freeradius3-utils
  $(call Package/freeradius3/Default)
  DEPENDS:=+freeradius3-common
  TITLE:=Misc. client utilities
endef

# This is a workaround for a bug in configure.ac, that does not check
# for the openss/rand.h header.  Setting the macro is safe for openwrt,
# and faster than rebuilding configure.
# This has been fixed upstream in the 3.0.x branch, and should not be
# needed in a future release.
EXTRA_CFLAGS+= -DHAVE_OPENSSL_RAND_H

CONFIGURE_ARGS+= \
	--libdir=/usr/lib/freeradius3 \
	--libexecdir=/usr/lib/freeradius3 \
	--disable-developer \
	--with-threads \
	$(if $(CONFIG_FREERADIUS3_OPENSSL),--with,--without)-openssl \
	$(if $(CONFIG_FREERADIUS3_OPENSSL),--with-openssl-includes="$(STAGING_DIR)/usr/include",) \
	$(if $(CONFIG_FREERADIUS3_OPENSSL),--with-openssl-libraries="$(STAGING_DIR)/usr/lib",) \
	$(if $(CONFIG_FREERADIUS3_OPENSSL),--disable-openssl-version-check,) \
	--with-talloc-include-dir="$(STAGING_DIR)/usr/include" \
	--with-talloc-lib-dir="$(STAGING_DIR)/usr/lib" \
	--enable-strict-dependencies \
	--with-dictdir=/usr/share/freeradius3 \
	--with-raddbdir=/etc/freeradius3 \
	--with-radacctdir=/var/db/radacct \
	--with-logdir=/var/log \
	--without-pcre \
	--without-rlm_cache_memcached \
	--without-rlm_couchbase \
	--without-rlm_eap_ikev2 \
	--without-rlm_eap_tnc \
	--without-rlm_perl \
	--without-rlm_python \
	--without-rlm_sql_db2 \
	--without-rlm_sql_firebird \
	--without-rlm_sql_freetds \
	--without-rlm_sql_iodbc \
	--without-rlm_sql_oracle \

CONFIGURE_LIBS+= -latomic

PKG_DICTIONARIES:= \
	compat \
	freeradius freeradius.internal \
	rfc2865 rfc2866 rfc2867 rfc2868 rfc2869 rfc3162 rfc3576 rfc3580 \
	rfc4072 rfc4372 rfc4675 rfc4679 rfc5580 rfc6911 \
	microsoft \
	wispr \

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-cache-redis),)
  CONFIGURE_ARGS+= \
		--with-rlm_cache_redis \
		--with-rlm_cache_redis-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_cache_redis-lib-dir="$(STAGING_DIR)/usr/lib"
else
  CONFIGURE_ARGS+= --without-rlm_cache_redis
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-eap-fast),)
  CONFIGURE_ARGS+= \
		--with-rlm_eap_fast \
		--with-rlm_eap_fast-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_eap_fast-lib-dir="$(STAGING_DIR)/usr/lib"
  CONFIGURE_LIBS+= -lcrypto -lssl
else
  CONFIGURE_ARGS+= --without-rlm_eap_fast
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-eap-peap),)
  CONFIGURE_ARGS+= \
		--with-rlm_eap_peap \
		--with-rlm_eap_peap-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_eap_peap-lib-dir="$(STAGING_DIR)/usr/lib"
  CONFIGURE_LIBS+= -lcrypto -lssl
else
  CONFIGURE_ARGS+= --without-rlm_eap_peap
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-eap-pwd),)
  CONFIGURE_ARGS+= \
		--with-rlm_eap_pwd \
		--with-rlm_eap_pwd-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_eap_pwd-lib-dir="$(STAGING_DIR)/usr/lib"
  CONFIGURE_LIBS+= -lcrypto -lssl
else
  CONFIGURE_ARGS+= --without-rlm_eap_pwd
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-eap-tls),)
  CONFIGURE_ARGS+= \
		--with-rlm_eap_tls \
		--with-rlm_eap_tls-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_eap_tls-lib-dir="$(STAGING_DIR)/usr/lib"
  CONFIGURE_LIBS+= -lcrypto -lssl
else
  CONFIGURE_ARGS+= --without-rlm_eap_tls
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-eap-ttls),)
  CONFIGURE_ARGS+= \
		--with-rlm_eap_ttls \
		--with-rlm_eap_ttls-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_eap_ttls-lib-dir="$(STAGING_DIR)/usr/lib"
  CONFIGURE_LIBS+= -lcrypto -lssl
else
  CONFIGURE_ARGS+= --without-rlm_eap_ttls
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-ippool),)
  CONFIGURE_ARGS+= --with-rlm_ippool \
		--with-rlm_ippool-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_ippool-lib-dir="$(STAGING_DIR)/usr/lib"
else
  CONFIGURE_ARGS+= --without-rlm_ippool
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-json),)
  CONFIGURE_ARGS+= --with-rlm_json \
		--with-rlm_json-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_json-lib-dir="$(STAGING_DIR)/usr/lib"
else
  CONFIGURE_ARGS+= --without-rlm_json
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-ldap),)
  CONFIGURE_ARGS+= --with-rlm_ldap \
		--with-rlm_ldap-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_ldap-lib-dir="$(STAGING_DIR)/usr/lib"
else
  CONFIGURE_ARGS+= --without-rlm_ldap
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-python3),)
  CFLAGS+= -fPIC
  CONFIGURE_ARGS+= \
		--with-modules="rlm_python3" \
		--with-rlm-python3-config-bin="$(STAGING_DIR)/host/bin/python$(PYTHON3_VERSION)-config"
else
  CONFIGURE_ARGS+= --without-rlm_python3
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-radutmp),)
  CONFIGURE_ARGS+= --with-rlm_radutmp
else
  CONFIGURE_ARGS+= --without-rlm_radutmp
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-redis),)
  CONFIGURE_ARGS+= \
		--with-rlm_redis \
		--with-rlm_redis-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_redis-lib-dir="$(STAGING_DIR)/usr/lib"
else
  CONFIGURE_ARGS+= --without-rlm_redis
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-rediswho),)
  CONFIGURE_ARGS+= \
		--with-rlm_rediswho \
		--with-rlm_rediswho-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_rediswho-lib-dir="$(STAGING_DIR)/usr/lib"
else
  CONFIGURE_ARGS+= --without-rlm_rediswho
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-rest),)
  CONFIGURE_ARGS+= --with-rlm_rest
else
  CONFIGURE_ARGS+= --without-rlm_rest
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-sql),)
  CONFIGURE_ARGS+= --with-rlm_sql
else
  CONFIGURE_ARGS+= --without-rlm_sql
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-sql-mysql),)
  CONFIGURE_ARGS+= \
		--with-rlm_sql_mysql \
		--with-mysql-include-dir="$(STAGING_DIR)/usr/include/mysql"
else
  CONFIGURE_ARGS+= --without-rlm_sql_mysql
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-sql-postgresql),)
  CONFIGURE_ARGS+= --with-rlm_sql_postgresql
else
  CONFIGURE_ARGS+= --without-rlm_sql_postgresql
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-sql-sqlite),)
  CONFIGURE_ARGS+= --with-rlm_sql_sqlite
else
  CONFIGURE_ARGS+= --without-rlm_sql_sqlite
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-unixodbc),)
  CONFIGURE_ARGS+= \
		--with-rlm_sql_unixodbc \
		--with-rlm_sql_unixodbc-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_sql_unixodbc-lib-dir="$(STAGING_DIR)/usr/lib"
else
  CONFIGURE_ARGS+= --without-rlm_sql_unixodbc
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-sqlcounter),)
  CONFIGURE_ARGS+= --with-rlm_sqlcounter
else
  CONFIGURE_ARGS+= --without-rlm_sqlcounter
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-sqlippool),)
  CONFIGURE_ARGS+= --with-rlm_sqlippool
else
  CONFIGURE_ARGS+= --without-rlm_sqlippool
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-unbound),)
  CONFIGURE_ARGS+= \
		--with-rlm_unbound \
		--with-rlm_unbound-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_unbound-lib-dir="$(STAGING_DIR)/usr/lib"
else
  CONFIGURE_ARGS+= --without-rlm_unbound
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-unix),)
  CONFIGURE_ARGS+= --with-rlm_unix
else
  CONFIGURE_ARGS+= --without-rlm_unix
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-yubikey),)
  CONFIGURE_ARGS+= \
		--with-rlm_yubikey \
		--with-rlm_yubikey-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_yubikey-lib-dir="$(STAGING_DIR)/usr/lib"
else
  CONFIGURE_ARGS+= --without-rlm_yubikey
endif

ifeq ($(CONFIG_USE_GLIBC),y)
  TARGET_CFLAGS+= -DLIBBSD_OVERLAY -I$(STAGING_DIR)/usr/include/bsd \
	-D_RPC_NETDB_H
	#^^^^^^^^^^^^^ avoid inclusion of librpc's netdb.h
  CONFIGURE_LIBS+= -Wl,--push-state,--as-needed -lbsd -Wl,--pop-state
endif

CONFIGURE_VARS+= \
	LDFLAGS="$$$$LDFLAGS" \
	LIBS="$(CONFIGURE_LIBS)" \
	MYSQL_CONFIG="no" \
	ac_cv_lib_readline=no \
	ax_cv_cc_builtin_choose_expr=yes \
	ax_cv_cc_builtin_types_compatible_p=yes ax_cv_cc_builtin_bswap64=yes \
	ax_cv_cc_bounded_attribute=no \
	ac_cv_lib_collectdclient_lcc_connect=no \
	ac_cv_lib_execinfo_backtrace_symbols=no

define Build/Compile
	# Compile jlibtool for the host once the configuration is done
	(cd $(PKG_BUILD_DIR); \
		mkdir -p build/make; \
		$(HOSTCC) $(HOST_CFLAGS) scripts/jlibtool.c -o build/make/jlibtool; \
	)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		R="$(PKG_INSTALL_DIR)" \
		INSTALLSTRIP="" \
		all install
endef

define Package/freeradius3-common/install
	$(INSTALL_DIR) $(1)/etc/freeradius3
	chmod 771 $(1)/etc/freeradius3
	$(CP) $(PKG_INSTALL_DIR)/etc/freeradius3/dictionary $(1)/etc/freeradius3/ ; \
	$(INSTALL_DIR) $(1)/usr/lib/freeradius3
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/freeradius3/libfreeradius-{dhcp,eap,radius,server}.so $(1)/usr/lib/freeradius3
	$(INSTALL_DIR) $(1)/usr/share/freeradius3
	$(CP) $(PKG_INSTALL_DIR)/usr/share/freeradius3/dictionary $(1)/usr/share/freeradius3/
	$(SED) "s,^\(\$$$$INCLUDE\),#\1,g" $(1)/usr/share/freeradius3/dictionary
	for f in $(PKG_DICTIONARIES); do \
		$(CP) $(PKG_INSTALL_DIR)/usr/share/freeradius3/dictionary.$$$${f} $(1)/usr/share/freeradius3/ ; \
		$(SED) "s,^#\(\$$$$INCLUDE dictionary\.$$$${f}\)$$$$,\1,g" $(1)/usr/share/freeradius3/dictionary ; \
	done
endef

define Package/freeradius3/install
	$(INSTALL_DIR) $(1)/etc/freeradius3
	$(INSTALL_DIR) $(1)/etc/freeradius3/policy.d
	$(INSTALL_DIR) $(1)/etc/freeradius3/sites-available
	$(INSTALL_DIR) $(1)/etc/freeradius3/sites-enabled
	for f in clients.conf radiusd.conf proxy.conf; do \
		$(CP) $(PKG_INSTALL_DIR)/etc/freeradius3/$$$${f} $(1)/etc/freeradius3/ ; \
	done
	for f in accounting filter; do \
		$(CP) $(PKG_INSTALL_DIR)/etc/freeradius3/policy.d/$$$${f} $(1)/etc/freeradius3/policy.d/ ; \
	done
	for f in default; do \
		$(CP) $(PKG_INSTALL_DIR)/etc/freeradius3/sites-available/$$$${f} $(1)/etc/freeradius3/sites-available/ ; \
		$(CP) $(PKG_INSTALL_DIR)/etc/freeradius3/sites-enabled/$$$${f} $(1)/etc/freeradius3/sites-enabled/ ; \
	done

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/radiusd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/radiusd.init $(1)/etc/init.d/radiusd
endef

define Package/freeradius3-default/install
	true
endef

define Package/freeradius3-democerts/install
	$(INSTALL_DIR) $(1)/etc/freeradius3/certs
	$(CP) \
		$(PKG_INSTALL_DIR)/etc/freeradius3/certs/ca.pem \
		$(PKG_INSTALL_DIR)/etc/freeradius3/certs/server.pem \
		$(1)/etc/freeradius3/certs/
endef

define Package/freeradius3-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	for f in radclient radeapclient radtest radwho; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$$$${f} $(1)/usr/bin/ ; \
	done
endef

define BuildPlugin
  define Package/$(1)/install
	[ -z "$(2)" ] || $(INSTALL_DIR) $$(1)/usr/lib/freeradius3
	for m in $(2); do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/freeradius3/$$$$$$$${m}.so $$(1)/usr/lib/freeradius3 ; \
	done
	# Install configuration files
	for f in $(strip $(call Package/$(1)/conffiles)); do \
		$(INSTALL_DIR) $$(1)/$$$$$$$${f%/*} ; \
		$(CP) $(PKG_INSTALL_DIR)/$$$$$$$${f} $$(1)/$$$$$$$${f}; \
	done
  endef

  $$(eval $$(call BuildPackage,$(1)))
endef


$(eval $(call BuildPackage,freeradius3))
$(eval $(call BuildPackage,freeradius3-common))
$(eval $(call BuildPackage,freeradius3-default))
$(eval $(call BuildPackage,freeradius3-democerts))
$(eval $(call BuildPlugin,freeradius3-mod-always,rlm_always,))
$(eval $(call BuildPlugin,freeradius3-mod-attr-filter,rlm_attr_filter,))
$(eval $(call BuildPlugin,freeradius3-mod-cache,rlm_cache,))
$(eval $(call BuildPlugin,freeradius3-mod-cache-rbtree,rlm_cache_rbtree,))
$(eval $(call BuildPlugin,freeradius3-mod-cache-redis,rlm_cache_redis,))
$(eval $(call BuildPlugin,freeradius3-mod-chap,rlm_chap,))
$(eval $(call BuildPlugin,freeradius3-mod-counter,rlm_counter,))
$(eval $(call BuildPlugin,freeradius3-mod-date,rlm_date,))
$(eval $(call BuildPlugin,freeradius3-mod-detail,rlm_detail,))
$(eval $(call BuildPlugin,freeradius3-mod-digest,rlm_digest,))
$(eval $(call BuildPlugin,freeradius3-mod-dpsk,rlm_dpsk,))
$(eval $(call BuildPlugin,freeradius3-mod-dynamic-clients,rlm_dynamic_clients,))
$(eval $(call BuildPlugin,freeradius3-mod-eap,rlm_eap,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-fast,rlm_eap_fast,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-gtc,rlm_eap_gtc,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-md5,rlm_eap_md5,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-mschapv2,rlm_eap_mschapv2,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-peap,rlm_eap_peap,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-pwd,rlm_eap_pwd,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-sim,rlm_eap_sim,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-tls,rlm_eap_tls,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-ttls,rlm_eap_ttls,))
$(eval $(call BuildPlugin,freeradius3-mod-exec,rlm_exec,))
$(eval $(call BuildPlugin,freeradius3-mod-expiration,rlm_expiration,))
$(eval $(call BuildPlugin,freeradius3-mod-expr,rlm_expr,))
$(eval $(call BuildPlugin,freeradius3-mod-files,rlm_files,))
$(eval $(call BuildPlugin,freeradius3-mod-ippool,rlm_ippool,))
$(eval $(call BuildPlugin,freeradius3-mod-json,rlm_json,))
$(eval $(call BuildPlugin,freeradius3-mod-krb5,rlm_krb5,))
$(eval $(call BuildPlugin,freeradius3-mod-ldap,rlm_ldap,))
$(eval $(call BuildPlugin,freeradius3-mod-linelog,rlm_linelog,))
$(eval $(call BuildPlugin,freeradius3-mod-logintime,rlm_logintime,))
$(eval $(call BuildPlugin,freeradius3-mod-mschap,rlm_mschap,))
$(eval $(call BuildPlugin,freeradius3-mod-pam,rlm_pam,))
$(eval $(call BuildPlugin,freeradius3-mod-pap,rlm_pap,))
$(eval $(call BuildPlugin,freeradius3-mod-passwd,rlm_passwd,))
$(eval $(call BuildPlugin,freeradius3-mod-preprocess,rlm_preprocess,))
$(eval $(call BuildPlugin,freeradius3-mod-python3,rlm_python3,))
$(eval $(call BuildPlugin,freeradius3-mod-radutmp,rlm_radutmp,))
$(eval $(call BuildPlugin,freeradius3-mod-realm,rlm_realm,))
$(eval $(call BuildPlugin,freeradius3-mod-redis,rlm_redis,))
$(eval $(call BuildPlugin,freeradius3-mod-rediswho,rlm_rediswho,))
$(eval $(call BuildPlugin,freeradius3-mod-replicate,rlm_replicate,))
$(eval $(call BuildPlugin,freeradius3-mod-rest,rlm_rest,))
$(eval $(call BuildPlugin,freeradius3-mod-soh,rlm_soh,))
$(eval $(call BuildPlugin,freeradius3-mod-sometimes,rlm_sometimes,))
$(eval $(call BuildPlugin,freeradius3-mod-sql,rlm_sql,))
$(eval $(call BuildPlugin,freeradius3-mod-sql-map,rlm_sql_map,))
$(eval $(call BuildPlugin,freeradius3-mod-sql-mysql,rlm_sql_mysql,))
$(eval $(call BuildPlugin,freeradius3-mod-sql-null,rlm_sql_null,))
$(eval $(call BuildPlugin,freeradius3-mod-sql-postgresql,rlm_sql_postgresql,))
$(eval $(call BuildPlugin,freeradius3-mod-sql-sqlite,rlm_sql_sqlite,))
$(eval $(call BuildPlugin,freeradius3-mod-sql-unixodbc,rlm_sql_unixodbc,))
$(eval $(call BuildPlugin,freeradius3-mod-sqlcounter,rlm_sqlcounter,))
$(eval $(call BuildPlugin,freeradius3-mod-sqlippool,rlm_sqlippool,))
$(eval $(call BuildPlugin,freeradius3-mod-totp,rlm_totp,))
$(eval $(call BuildPlugin,freeradius3-mod-unbound,rlm_unbound,))
$(eval $(call BuildPlugin,freeradius3-mod-unix,rlm_unix,))
$(eval $(call BuildPlugin,freeradius3-mod-unpack,rlm_unpack,))
$(eval $(call BuildPlugin,freeradius3-mod-utf8,rlm_utf8,))
$(eval $(call BuildPlugin,freeradius3-mod-wimax,rlm_wimax,))
$(eval $(call BuildPlugin,freeradius3-mod-yubikey,rlm_yubikey,))
$(eval $(call BuildPackage,freeradius3-utils))
