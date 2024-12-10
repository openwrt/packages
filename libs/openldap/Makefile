#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openldap
PKG_VERSION:=2.6.8
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=https://mirror.eu.oneandone.net/software/openldap/openldap-release/ \
	https://www.openldap.org/software/download/OpenLDAP/openldap-release/
PKG_HASH:=48969323e94e3be3b03c6a132942dcba7ef8d545f2ad35401709019f696c3c4e
PKG_LICENSE:=OLDAP-2.8
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:openldap:openldap

PKG_FIXUP:=autoreconf

# Fixes the following:
# libtool: Version mismatch error.  This is libtool 2.4.2, but the
# libtool: definition of this LT_INIT comes from libtool 2.4.6.
# libtool: You should recreate aclocal.m4 with macros from libtool 2.4.2
# libtool: and run autoconf again.
PKG_REMOVE_FILES:=build/ltversion.m4

PKG_CONFIG_DEPENDS := \
        CONFIG_OPENLDAP_DEBUG \
        CONFIG_OPENLDAP_CRYPT \
        CONFIG_OPENLDAP_MONITOR \
        CONFIG_OPENLDAP_DB47 \
        CONFIG_OPENLDAP_ICU

include $(INCLUDE_DIR)/package.mk

define Package/libopenldap/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=OpenLDAP
  TITLE:=LDAP directory suite
  URL:=https://www.openldap.org/
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
endef

define Package/libopenldap
  $(call Package/libopenldap/Default)
  MENU:=1
  DEPENDS:=+libopenssl +libsasl2 +libpthread +libuuid +OPENLDAP_DB47:libdb47 +OPENLDAP_ICU:icu
  TITLE+= (libraries)
endef

define Package/libopenldap/config
  source "$(SOURCE)/Config.in"
endef

define Package/openldap/config
  source "$(SOURCE)/Config.in"
endef

define Package/libopenldap/description
OpenLDAP Software is an open source implementation of the Lightweight Directory Access Protocol (LDAP). This package contains the shared LDAP client libraries, needed by other programs.
endef

define Package/libopenldap/conffiles
/etc/openldap/ldap.conf
endef

define Package/openldap-utils
  $(call Package/libopenldap/Default)
  DEPENDS:=+libopenldap
  TITLE+= (utilities)
endef

define Package/openldap-utils/description
This package contains client programs required to access LDAP servers.
endef

define Package/openldap-server
  $(call Package/libopenldap/Default)
  DEPENDS:=+libopenldap +libuuid
  TITLE+= (server)
endef

define Package/openldap-server/description
This package contains server programs required to provide LDAP services.
endef

define Package/openldap-server/conffiles
/etc/openldap/slapd.conf
/etc/init.d/ldap
endef

TARGET_CFLAGS += $(FPIC) -lpthread \
	-DURANDOM_DEVICE=\\\"/dev/urandom\\\"

CONFIGURE_ARGS += \
	--enable-dynamic \
	--enable-syslog \
	--with-cyrus-sasl \
	--with-threads \
	--with-tls \
	--with-yielding-select="yes" \
	--enable-null \
	--disable-relay


ifdef CONFIG_OPENLDAP_CRYPT
	CONFIGURE_ARGS+= --enable-crypt
else
	CONFIGURE_ARGS+= --disable-crypt
endif

ifdef CONFIG_OPENLDAP_MONITOR
	CONFIGURE_ARGS+= --enable-monitor
else
	CONFIGURE_ARGS+= --disable-monitor
endif

ifdef CONFIG_OPENLDAP_DEBUG
	CONFIGURE_ARGS+= --enable-debug
else
	CONFIGURE_ARGS+= --disable-debug
endif

ifdef CONFIG_OPENLDAP_DB47
	CONFIGURE_ARGS+= \
		--enable-bdb \
		--enable-hdb
else
	CONFIGURE_ARGS+= \
		--disable-bdb \
		--disable-hdb
endif

ifndef CONFIG_OPENLDAP_ICU
	CONFIGURE_VARS += \
		ol_cv_lib_icu="no"
endif

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		HOSTCC="$(HOSTCC)" \
		depend all install
	cd $(PKG_BUILD_DIR)/libraries/liblmdb && $(MAKE) $(CONFIGURE_VARS)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/{lber,ldap}*.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{lber,ldap}*.{a,so*} $(1)/usr/lib/
endef

define Package/libopenldap/install
	$(INSTALL_DIR) $(1)/etc/openldap $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/etc/openldap/ldap.conf $(1)/etc/openldap/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{lber,ldap}*.so.* $(1)/usr/lib/
endef

define Package/openldap-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ldap* $(1)/usr/bin/
endef

define Package/openldap-server/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ldap.init $(1)/etc/init.d/ldap
	$(INSTALL_DIR) $(1)/etc/openldap/schema
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/openldap/schema/* $(1)/etc/openldap/schema/
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/openldap/slapd.conf $(1)/etc/openldap/
	$(INSTALL_DIR) $(1)/usr/sbin
	# NB: OpenLDAP installs slapd into libexecdir, not sbindir
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/slapd $(1)/usr/sbin/
	$(eval SLAPTOOLS := slapadd slapcat slapdn slapindex slappasswd slaptest slapauth slapacl slapschema)
	for i in $(SLAPTOOLS); do \
		$(LN) ./slapd $(1)/usr/sbin/$$$$i; \
	done
endef

$(eval $(call BuildPackage,libopenldap))
$(eval $(call BuildPackage,openldap-utils))
$(eval $(call BuildPackage,openldap-server))
