#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=freeradius2
PKG_VERSION:=2.2.8
PKG_RELEASE:=2

PKG_SOURCE:=freeradius-server-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=\
	ftp://ftp.freeradius.org/pub/freeradius/ \
	ftp://ftp.freeradius.org/pub/freeradius/old/
PKG_MD5SUM:=0adc2454392ab8a43664dea416022e28
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYRIGHT LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/freeradius-server-$(PKG_VERSION)
PKG_FIXUP:=autoreconf
PKG_CHECK_FORMAT_SECURITY:=0

PKG_CONFIG_DEPENDS := \
  FREERADIUS_OPENSSL \
  FREERADIUS_NOSSL

PKG_CHECK_FORMAT_SECURITY:=0
include $(INCLUDE_DIR)/package.mk

define Package/freeradius2/config
  source "$(SOURCE)/Config.in"
endef

define Package/freeradius2/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=http://freeradius.org/
  SUBMENU:=FreeRADIUS (version 2)
endef

define Package/freeradius2
  $(call Package/freeradius2/Default)
  DEPENDS:=+libltdl +libreadline +freeradius2-common
  TITLE:=A flexible RADIUS server (version 2)
endef

define Package/freeradius2/conffiles
/etc/freeradius2/clients.conf
/etc/freeradius2/radiusd.conf
/etc/freeradius2/sites/default
endef

define Package/freeradius2-democerts
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=Demo certificates to test the server
endef

define Package/freeradius2-common
  $(call Package/freeradius2/Default)
  TITLE:=common files
  DEPENDS:=+libpthread +FREERADIUS_OPENSSL:libopenssl
endef

define Package/freeradius2-mod-chap
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=CHAP module
endef

define Package/freeradius2-mod-chap/conffiles
/etc/freeradius2/modules/chap
endef

define Package/freeradius2-mod-detail
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=Detailed accounting module
endef

define Package/freeradius2-mod-detail/conffiles
/etc/freeradius2/modules/detail
endef

define Package/freeradius2-mod-eap
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=Base EAP module
endef

define Package/freeradius2-mod-eap/conffiles
/etc/freeradius2/eap.conf
endef

define Package/freeradius2-mod-eap-gtc
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2-mod-eap
  TITLE:=EAP/GTC module
endef

define Package/freeradius2-mod-eap-md5
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2-mod-eap
  TITLE:=EAP/MD5 module
endef

define Package/freeradius2-mod-eap-mschapv2
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2-mod-eap +freeradius2-mod-mschap
  TITLE:=EAP/MS-CHAPv2 module
endef

define Package/freeradius2-mod-eap-peap
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2-mod-eap @FREERADIUS_OPENSSL
  TITLE:=EAP/PEAP module
endef

define Package/freeradius2-mod-eap-tls
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2-mod-eap @FREERADIUS_OPENSSL
  TITLE:=EAP/TLS module
endef

define Package/freeradius2-mod-eap-ttls
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2-mod-eap-tls
  TITLE:=EAP/TTLS module
endef

define Package/freeradius2-mod-exec
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=EXEC module
endef

define Package/freeradius2-mod-exec/conffiles
/etc/freeradius2/modules/exec
endef

define Package/freeradius2-mod-expiration
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=Expiration module
endef

define Package/freeradius2-mod-expiration/conffiles
/etc/freeradius2/modules/expiration
endef

define Package/freeradius2-mod-always
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=Always module
endef

define Package/freeradius2-mod-always/conffiles
/etc/freeradius2/modules/always
endef

define Package/freeradius2-mod-expr
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=EXPR module
endef

define Package/freeradius2-mod-expr/conffiles
/etc/freeradius2/modules/expr
endef

define Package/freeradius2-mod-attr-filter
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=ATTR filter module
endef

define Package/freeradius2-mod-attr-filter/conffiles
/etc/freeradius2/modules/attr_filter
/etc/freeradius2/attrs
/etc/freeradius2/attrs.access_reject
/etc/freeradius2/attrs.accounting_response
/etc/freeradius2/attrs.pre-proxy
endef

define Package/freeradius2-mod-attr-rewrite
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=ATTR rewrite module
endef

define Package/freeradius2-mod-attr-rewrite/conffiles
/etc/freeradius2/modules/attr_rewrite
endef

define Package/freeradius2-mod-files
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=Module using local files for authorization
endef

define Package/freeradius2-mod-files/conffiles
/etc/freeradius2/acct_users
/etc/freeradius2/preproxy_users
/etc/freeradius2/users
/etc/freeradius2/modules/files
endef

define Package/freeradius2-mod-passwd
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=Rlm passwd module
endef

define Package/freeradius2-mod-passwd/conffiles
/etc/freeradius2/modules/passwd
endef

define Package/freeradius2-mod-ldap
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2 +libopenldap
  TITLE:=LDAP module
endef

define Package/freeradius2-mod-ldap/conffiles
/etc/freeradius2/ldap.attrmap
/etc/freeradius2/modules/ldap
endef

define Package/freeradius2-mod-logintime
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=Logintime module
endef

define Package/freeradius2-mod-logintime/conffiles
/etc/freeradius2/modules/logintime
endef

define Package/freeradius2-mod-mschap
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=MS-CHAP and MS-CHAPv2 module
endef

define Package/freeradius2-mod-mschap/conffiles
/etc/freeradius2/modules/mschap
endef

define Package/freeradius2-mod-pap
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=PAP module
endef

define Package/freeradius2-mod-pap/conffiles
/etc/freeradius2/modules/pap
endef

define Package/freeradius2-mod-preprocess
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=Request pre-processing module
endef

define Package/freeradius2-mod-preprocess/conffiles
/etc/freeradius2/hints
/etc/freeradius2/huntgroups
/etc/freeradius2/modules/preprocess
endef

define Package/freeradius2-mod-realm
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=Realms handling module
endef

define Package/freeradius2-mod-realm/conffiles
/etc/freeradius2/proxy.conf
/etc/freeradius2/modules/realm
endef

define Package/freeradius2-mod-sql
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=Base SQL module
endef

define Package/freeradius2-mod-sql/conffiles
/etc/freeradius2/sql.conf
endef

define Package/freeradius2-mod-sql-mysql
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2-mod-sql +libmysqlclient-r
  TITLE:=MySQL module
endef

define Package/freeradius2-mod-sql-pgsql
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2-mod-sql +libpq
  TITLE:=PostgreSQL module
endef

define Package/freeradius2-mod-sql-sqlite
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2-mod-sql +libsqlite3
  TITLE:=SQLite module
endef

define Package/freeradius2-mod-sqlcounter
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2-mod-sql
  TITLE:=Generic SQL Counter module
endef

define Package/freeradius2-mod-radutmp
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=Radius UTMP module
endef

define Package/freeradius2-mod-radutmp/conffiles
/etc/freeradius2/modules/radutmp
/etc/freeradius2/modules/sradutmp
endef

define Package/freeradius2-utils
  $(call Package/freeradius2/Default)
  DEPENDS:=+freeradius2-common
  TITLE:=Misc. client utilities
endef

define Package/freeradius2-mod-sqllog
  $(call Package/freeradius2/Default)
  DEPENDS:=freeradius2
  TITLE:=SQL Logging module
endef

CONFIGURE_ARGS+= \
	--libdir=/usr/lib/freeradius2 \
	--libexecdir=/usr/lib/freeradius2 \
	--enable-shared \
	--disable-static \
	--disable-developer \
	--with-threads \
	$(if $(CONFIG_FREERADIUS_OPENSSL),--with,--without)-openssl \
	$(if $(CONFIG_FREERADIUS_OPENSSL),--with-openssl-includes="$(STAGING_DIR)/usr/include",) \
	$(if $(CONFIG_FREERADIUS_OPENSSL),--with-openssl-libraries="$(STAGING_DIR)/usr/lib",) \
	$(if $(CONFIG_FREERADIUS_OPENSSL),--disable-openssl-version-check,) \
	--with-system-libtool \
	--with-system-libltdl \
	--enable-strict-dependencies \
	--with-raddbdir=/etc/freeradius2 \
	--with-radacctdir=/var/db/radacct \
	--with-logdir=/var/log \
	--without-edir \
	--without-snmp \
	--without-rlm_checkval \
	--without-rlm_dbm \
	--without-rlm_counter \
	--with-rlm_expr \
	--with-rlm_eap \
	--without-rlm_eap_sim \
	--without-rlm_example \
	--without-rlm_ippool \
	--without-rlm_krb5 \
	--without-rlm_otp \
	--without-rlm_smsotp \
	--without-rlm_pam \
	--without-rlm_perl \
	--without-rlm_python \
	--without-rlm_smb \
	--with-rlm_sql \
	--with-rlm_sqlcounter \
	--without-rlm_sqlhpwippool \
	--without-rlm_sqlippool \
	--without-rlm_sql_db2 \
	--without-rlm_sql_firebird \
	--without-rlm_sql_freetds \
	--without-rlm_sql_iodbc \
	--without-rlm_sql_oracle \
	--without-rlm_sql_sybase \
	--without-rlm_sql_unixodbc \
	--without-rlm_sql_log \
	--without-rlm_unix \
	--without-rlm_eap_tnc \
	--without-rlm_eap_ikev2 \
	--without-rlm_opendirectory \
	--without-rlm_wimax \
	--without-rlm_ruby \
	--without-rlm_caching \
	--without-rlm_redis \
	--without-rlm_rediswho \
	--without-rlm_soh \
	--without-rlm_sim \
	--without-rlm_replicate \
	--without-rlm_protocol_filter \
	--without-rlm_policy \
	--without-rlm_linelog \
	--without-rlm_jradius \
	--without-rlm_fastusers \
	--without-rlm_eap_leap \
	--without-rlm_dynamic_clients \
	--without-rlm_digest \
	--without-rlm_cram \
	--without-rlm_copy_packet \
	--without-rlm_acct_unique \
	--without-rlm_acctlog
	

PKG_DICTIONARIES:= \
	freeradius freeradius.internal \
	rfc2865 rfc2866 rfc2867 rfc2868 rfc2869 rfc3162 rfc3576 rfc3580 \
	rfc4372 rfc4675 rfc4679 \
	microsoft \
	wispr \

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius2-mod-ldap),)
  CONFIGURE_ARGS+= \
		--with-rlm_ldap-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_ldap-lib-dir="$(STAGING_DIR)/usr/lib"
  CONFIGURE_LIBS+= -lcrypto -lssl
else
  CONFIGURE_ARGS+= --without-rlm_ldap
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius2-mod-sql-mysql),)
  CONFIGURE_ARGS+= \
		--with-mysql-include-dir="$(STAGING_DIR)/usr/include" \
		--with-mysql-lib-dir="$(STAGING_DIR)/usr/lib/mysql"
  CONFIGURE_LIBS+= -lz
  CONFIGURE_VARS+= ac_cv_lib_mysqlclient_r_mysql_init=yes
else
  CONFIGURE_ARGS+= --without-rlm_sql_mysql
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius2-mod-sql-pgsql),)
  CONFIGURE_ARGS+= \
		--with-rlm_sql_postgresql-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_sql_postgresql-lib-dir="$(STAGING_DIR)/usr/lib"
else
  CONFIGURE_ARGS+= --without-rlm_sql_postgresql
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius2-mod-sqllog),)
  CONFIGURE_ARGS+= \
        --with-rlm_sql_log \
        --with-experimental-modules \
else
  CONFIGURE_ARGS+= --without-rlm_sql_log
endif


ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius2-mod-sql-sqlite),)
  CONFIGURE_ARGS+= \
	--with-rlm_sql_sqlite \
	--with-experimental-modules \
	--with-sqlite-include-dir="$(STAGING_DIR)/usr/include" \
	--with-sqlite-lib-dir="$(STAGING_DIR)/usr/lib"
else
  CONFIGURE_ARGS+= --without-rlm_sql_sqlite
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius2-mod-eap-peap),)
  CONFIGURE_ARGS+= \
  		--with-rlm_eap_peap \
		--with-rlm_eap_peap-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_eap_peap-lib-dir="$(STAGING_DIR)/usr/lib"
  CONFIGURE_LIBS+= -lcrypto -lssl
else
  CONFIGURE_ARGS+= --without-rlm_eap_peap
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius2-mod-eap-tls),)
  CONFIGURE_ARGS+= \
  		--with-rlm_eap_tls \
		--with-rlm_eap_tls-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_eap_tls-lib-dir="$(STAGING_DIR)/usr/lib"
  CONFIGURE_LIBS+= -lcrypto -lssl
else
  CONFIGURE_ARGS+= --without-rlm_eap_tls
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius2-mod-eap-ttls),)
  CONFIGURE_ARGS+= \
  		--with-rlm_eap_ttls \
		--with-rlm_eap_ttls-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_eap_ttls-lib-dir="$(STAGING_DIR)/usr/lib"
  CONFIGURE_LIBS+= -lcrypto -lssl
else
  CONFIGURE_ARGS+= --without-rlm_eap_ttls
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius2-mod-attr-rewrite),)
  CONFIGURE_ARGS+= --with-rlm_attr-rewrite
else
  CONFIGURE_ARGS+= --without-rlm_attr-rewrite
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius2-mod-radutmp),)
  CONFIGURE_ARGS+= --with-rlm_radutmp
else
  CONFIGURE_ARGS+= --without-rlm_radutmp
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius2-mod-logintime),)
  CONFIGURE_ARGS+= --with-rlm_logintime
else
  CONFIGURE_ARGS+= --without-rlm_logintime
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius2-mod-expiration),)
  CONFIGURE_ARGS+= --with-rlm_expiration
else
  CONFIGURE_ARGS+= --without-rlm_expiration
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius2-mod-always),)
  CONFIGURE_ARGS+= --with-rlm_always
else
  CONFIGURE_ARGS+= --without-rlm_always
endif

CONFIGURE_VARS+= \
	LDFLAGS="$$$$LDFLAGS" \
	LIBS="$(CONFIGURE_LIBS)" \
	MYSQL_CONFIG="no" \
	ac_cv_lib_readline=no \

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		R="$(PKG_INSTALL_DIR)" \
		INSTALLSTRIP="" \
		all certs install
endef

define Package/freeradius2-common/install
	$(INSTALL_DIR) $(1)/etc/freeradius2
	chmod 771 $(1)/etc/freeradius2
	$(CP) $(PKG_INSTALL_DIR)/etc/freeradius2/dictionary $(1)/etc/freeradius2/ ; \
	$(INSTALL_DIR) $(1)/usr/lib/freeradius2
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/freeradius2/libfreeradius-radius{,-*}.so $(1)/usr/lib/freeradius2
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/freeradius2/libfreeradius-eap{,-*}.so $(1)/usr/lib/freeradius2
	$(INSTALL_DIR) $(1)/usr/share/freeradius2
	$(CP) $(PKG_INSTALL_DIR)/usr/share/freeradius/dictionary $(1)/usr/share/freeradius2/
	$(SED) "s,^\(\$$$$INCLUDE\),#\1,g" $(1)/usr/share/freeradius2/dictionary
	for f in $(PKG_DICTIONARIES); do \
		$(CP) $(PKG_INSTALL_DIR)/usr/share/freeradius/dictionary.$$$${f} $(1)/usr/share/freeradius2/ ; \
		$(SED) "s,^#\(\$$$$INCLUDE dictionary\.$$$${f}\),\1,g" $(1)/usr/share/freeradius2/dictionary ; \
	done
endef

define Package/freeradius2/install
	$(INSTALL_DIR) $(1)/etc/freeradius2/modules
	$(INSTALL_DIR) $(1)/etc/freeradius2/sites
	for f in clients.conf radiusd.conf policy.conf; do \
		$(CP) $(PKG_INSTALL_DIR)/etc/freeradius2/$$$${f} $(1)/etc/freeradius2/ ; \
	done
	$(CP) $(PKG_INSTALL_DIR)/etc/freeradius2/sites-available/default $(1)/etc/freeradius2/sites/default
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/radiusd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/radiusd.init $(1)/etc/init.d/radiusd
endef

define Package/freeradius2-democerts/install
	$(INSTALL_DIR) $(1)/etc/freeradius2/certs
	$(CP) \
		$(PKG_BUILD_DIR)/raddb/certs/ca.pem \
		$(PKG_BUILD_DIR)/raddb/certs/dh \
		$(PKG_BUILD_DIR)/raddb/certs/random \
		$(PKG_BUILD_DIR)/raddb/certs/server.pem \
		$(1)/etc/freeradius2/certs/
endef

define Package/freeradius2-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	for f in radclient radeapclient radwho; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$$$${f} $(1)/usr/bin/ ; \
	done
endef

define BuildPlugin
  define Package/$(1)/install
	[ -z "$(2)" ] || $(INSTALL_DIR) $$(1)/usr/lib/freeradius2
	for m in $(2); do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/freeradius2/$$$$$$$${m}{,-*}.so $$(1)/usr/lib/freeradius2 ; \
	done
	[ -z "$(3)" ] || $(INSTALL_DIR) $$(1)/etc/freeradius2
	[ -z "$(4)" ] || $(INSTALL_DIR) $$(1)/etc/freeradius2/$(4)
	for f in $(3); do \
		$(CP) $(PKG_INSTALL_DIR)/etc/freeradius2/$$$$$$$${f} $$(1)/etc/freeradius2/$$$$$$$${f} ; \
	done
  endef

  $$(eval $$(call BuildPackage,$(1)))
endef

$(eval $(call BuildPackage,freeradius2))
$(eval $(call BuildPackage,freeradius2-common))
$(eval $(call BuildPackage,freeradius2-democerts))
$(eval $(call BuildPlugin,freeradius2-mod-chap,rlm_chap,modules/chap,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-detail,rlm_detail,modules/detail,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-eap,rlm_eap,eap.conf))
$(eval $(call BuildPlugin,freeradius2-mod-eap-gtc,rlm_eap_gtc,))
$(eval $(call BuildPlugin,freeradius2-mod-eap-md5,rlm_eap_md5,))
$(eval $(call BuildPlugin,freeradius2-mod-eap-mschapv2,rlm_eap_mschapv2,))
$(eval $(call BuildPlugin,freeradius2-mod-eap-peap,rlm_eap_peap,))
$(eval $(call BuildPlugin,freeradius2-mod-eap-tls,rlm_eap_tls,))
$(eval $(call BuildPlugin,freeradius2-mod-eap-ttls,rlm_eap_ttls,))
$(eval $(call BuildPlugin,freeradius2-mod-exec,rlm_exec,modules/exec modules/echo ,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-attr-rewrite,rlm_attr_rewrite,modules/attr_rewrite,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-files,rlm_files,acct_users preproxy_users users modules/files,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-passwd,rlm_passwd,modules/passwd,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-ldap,rlm_ldap,ldap.attrmap modules/ldap,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-mschap,rlm_mschap,modules/mschap,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-pap,rlm_pap,modules/pap,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-preprocess,rlm_preprocess,hints huntgroups modules/preprocess,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-realm,rlm_realm,proxy.conf modules/realm modules/inner-eap,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-sql,rlm_sql,sql.conf,))
$(eval $(call BuildPlugin,freeradius2-mod-sql-mysql,rlm_sql_mysql,))
$(eval $(call BuildPlugin,freeradius2-mod-sql-pgsql,rlm_sql_postgresql,))
$(eval $(call BuildPlugin,freeradius2-mod-sql-sqlite,rlm_sql_sqlite,))
$(eval $(call BuildPlugin,freeradius2-mod-sqlcounter,rlm_sqlcounter,))
$(eval $(call BuildPlugin,freeradius2-mod-sqllog,rlm_sql_log,))
$(eval $(call BuildPlugin,freeradius2-mod-radutmp,rlm_radutmp,modules/radutmp modules/sradutmp,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-logintime,rlm_logintime,modules/logintime,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-expr,rlm_expr,modules/expr,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-attr-filter,rlm_attr_filter,modules/attr_filter attrs attrs.access_reject attrs.accounting_response attrs.pre-proxy,modules,,))
$(eval $(call BuildPlugin,freeradius2-mod-expiration,rlm_expiration,modules/expiration,modules,))
$(eval $(call BuildPlugin,freeradius2-mod-always,rlm_always,modules/always,modules,))
$(eval $(call BuildPackage,freeradius2-utils))
