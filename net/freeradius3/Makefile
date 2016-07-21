#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=freeradius3
PKG_VERSION:=release_3_0_11
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/FreeRADIUS/freeradius-server/archive
PKG_MD5SUM:=612cb1d9ad0d66e881d8b0592cd51720

PKG_MAINTAINER:=Lucile Quirion <lucile.quirion@savoirfairelinux.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYRIGHT LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/freeradius-server-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

PKG_CONFIG_DEPENDS := \
  FREERADIUS3_OPENSSL \
  FREERADIUS3_NOSSL

include $(INCLUDE_DIR)/package.mk

define Package/freeradius3/config
  source "$(SOURCE)/Config.in"
endef

define Package/freeradius3/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=http://freeradius.org/
  SUBMENU:=FreeRADIUS (version 3)
endef

define Package/freeradius3
  $(call Package/freeradius3/Default)
  DEPENDS:=+freeradius3-common
  TITLE:=A flexible RADIUS server (version 3)
endef

define Package/freeradius3/conffiles
/etc/freeradius3/clients.conf
/etc/freeradius3/radiusd.conf
/etc/freeradius3/sites/default
endef

define Package/freeradius3-common
  $(call Package/freeradius3/Default)
  TITLE:=common files
  DEPENDS:=+USE_GLIBC:libpthread +FREERADIUS3_OPENSSL:libopenssl +libcap +libpcap +libncurses +PACKAGE_libpcre:libpcre +libreadline +libtalloc
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
+freeradius3-mod-eap-leap \
+freeradius3-mod-eap-md5 \
+freeradius3-mod-eap-mschapv2 \
+freeradius3-mod-eap-peap \
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

define Package/freeradius3-democerts
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Demo certificates to test the server
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

define Package/freeradius3-mod-eap
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Base EAP module
endef

define Package/freeradius3-mod-eap/conffiles
/etc/freeradius3/mods-available/eap
/etc/freeradius3/mods-enabled/eap
/etc/freeradius3/policy.d/eap
endef

define Package/freeradius3-mod-eap-gtc
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-eap
  TITLE:=EAP/GTC module
endef

define Package/freeradius3-mod-eap-leap
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3-mod-eap
  TITLE:=EAP/LEAP module
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

define Package/freeradius3-mod-eap-peap/conffiles
/etc/freeradius3/sites-available/inner-tunnel
/etc/freeradius3/sites-enabled/inner-tunnel
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

define Package/freeradius3-mod-eap-ttls/conffiles
/etc/freeradius3/sites-available/inner-tunnel
/etc/freeradius3/sites-enabled/inner-tunnel
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

define Package/freeradius3-mod-always
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Always module
endef

define Package/freeradius3-mod-always/conffiles
/etc/freeradius3/mods-available/always
/etc/freeradius3/mods-enabled/always
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
/etc/freeradius3/mods-config/attr_filter/post-proxy
/etc/freeradius3/mods-config/attr_filter/pre-proxy
endef

define Package/freeradius3-mod-attr-rewrite
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=ATTR rewrite module
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

define Package/freeradius3-mod-passwd
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Rlm passwd module
endef

define Package/freeradius3-mod-passwd/conffiles
/etc/freeradius3/mods-available/passwd
/etc/freeradius3/mods-enabled/passwd
endef

# LDAP support has not been ported

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

define Package/freeradius3-mod-pap
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=PAP module
endef

define Package/freeradius3-mod-pap/conffiles
/etc/freeradius3/mods-available/pap
/etc/freeradius3/mods-enabled/pap
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

define Package/freeradius3-mod-realm
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=Realms handling module
endef

define Package/freeradius3-mod-realm/conffiles
/etc/freeradius3/proxy.conf
/etc/freeradius3/mods-available/realm
/etc/freeradius3/mods-enabled/realm
endef

# SQL support has not been ported

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

define Package/freeradius3-mod-unix
  $(call Package/freeradius3/Default)
  DEPENDS:=freeradius3
  TITLE:=System Authentication
endef

define Package/freeradius3-mod-unix/conffiles
/etc/freeradius3/mods-available/unix
/etc/freeradius3/mods-enabled/unix
endef

define Package/freeradius3-utils
  $(call Package/freeradius3/Default)
  DEPENDS:=+freeradius3-common
  TITLE:=Misc. client utilities
endef

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
	--without-edir \
	--without-snmp \
	--without-rlm_cache \
	--without-rlm_cache_memcached \
	--without-rlm_couchbase \
	--without-rlm_counter \
	--without-rlm_eap_ikev2 \
	--without-rlm_eap_pwd \
	--without-rlm_eap_sim \
	--without-rlm_eap_tnc \
	--without-rlm_example \
	--without-rlm_idn \
	--without-rlm_ippool \
	--without-rlm_krb5 \
	--without-rlm_ldap \
	--without-rlm_opendirectory \
	--without-rlm_pam \
	--without-rlm_perl \
	--without-rlm_python \
	--without-rlm_redis \
	--without-rlm_rediswho \
	--without-rlm_rest \
	--without-rlm_ruby \
	--without-rlm_securid \
	--without-rlm_smsotp \
	--without-rlm_sql \
	--without-rlm_sql_db2 \
	--without-rlm_sql_firebird \
	--without-rlm_sql_freetds \
	--without-rlm_sql_iodbc \
	--without-rlm_sql_mysql \
	--without-rlm_sql_oracle \
	--without-rlm_sql_postgresql \
	--without-rlm_sql_sqlite \
	--without-rlm_sql_unixodbc \
	--without-rlm_sqlcounter \
	--without-rlm_sqlhpwippool \
	--without-rlm_sqlippool \
	--without-rlm_unbound \
	--without-rlm_yubikey \

PKG_DICTIONARIES:= \
	compat \
	freeradius freeradius.internal \
	rfc2865 rfc2866 rfc2867 rfc2868 rfc2869 rfc3162 rfc3576 rfc3580 \
	rfc4372 rfc4675 rfc4679 rfc5580\
	microsoft \
	wispr \

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-eap-peap),)
  CONFIGURE_ARGS+= \
		--with-rlm_eap_peap \
		--with-rlm_eap_peap-include-dir="$(STAGING_DIR)/usr/include" \
		--with-rlm_eap_peap-lib-dir="$(STAGING_DIR)/usr/lib"
  CONFIGURE_LIBS+= -lcrypto -lssl
else
  CONFIGURE_ARGS+= --without-rlm_eap_peap
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

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-radutmp),)
  CONFIGURE_ARGS+= --with-rlm_radutmp
else
  CONFIGURE_ARGS+= --without-rlm_radutmp
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_freeradius3-mod-unix),)
  CONFIGURE_ARGS+= --with-rlm_unix
else
  CONFIGURE_ARGS+= --without-rlm_unix
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

define Package/freeradius3-democerts/install
	$(INSTALL_DIR) $(1)/etc/freeradius3/certs
	$(CP) \
		$(PKG_INSTALL_DIR)/etc/freeradius3/certs/ca.pem \
		$(PKG_INSTALL_DIR)/etc/freeradius3/certs/dh \
		$(PKG_INSTALL_DIR)/etc/freeradius3/certs/server.pem \
		$(1)/etc/freeradius3/certs/
endef

define Package/freeradius3-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	for f in radclient radeapclient radwho; do \
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
$(eval $(call BuildPlugin,freeradius3-mod-chap,rlm_chap,))
$(eval $(call BuildPlugin,freeradius3-mod-detail,rlm_detail,))
$(eval $(call BuildPlugin,freeradius3-mod-digest,rlm_digest,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-gtc,rlm_eap_gtc,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-leap,rlm_eap_leap,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-md5,rlm_eap_md5,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-mschapv2,rlm_eap_mschapv2,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-peap,rlm_eap_peap,))
$(eval $(call BuildPlugin,freeradius3-mod-eap,rlm_eap,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-tls,rlm_eap_tls,))
$(eval $(call BuildPlugin,freeradius3-mod-eap-ttls,rlm_eap_ttls,))
$(eval $(call BuildPlugin,freeradius3-mod-exec,rlm_exec,))
$(eval $(call BuildPlugin,freeradius3-mod-expiration,rlm_expiration,))
$(eval $(call BuildPlugin,freeradius3-mod-expr,rlm_expr,))
$(eval $(call BuildPlugin,freeradius3-mod-files,rlm_files,))
$(eval $(call BuildPlugin,freeradius3-mod-logintime,rlm_logintime,))
$(eval $(call BuildPlugin,freeradius3-mod-mschap,rlm_mschap,))
$(eval $(call BuildPlugin,freeradius3-mod-pap,rlm_pap,))
$(eval $(call BuildPlugin,freeradius3-mod-passwd,rlm_passwd,))
$(eval $(call BuildPlugin,freeradius3-mod-preprocess,rlm_preprocess,))
$(eval $(call BuildPlugin,freeradius3-mod-radutmp,rlm_radutmp,))
$(eval $(call BuildPlugin,freeradius3-mod-realm,rlm_realm,))
$(eval $(call BuildPlugin,freeradius3-mod-unix,rlm_unix,))
$(eval $(call BuildPackage,freeradius3-utils))
