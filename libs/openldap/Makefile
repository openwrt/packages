#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openldap
PKG_VERSION:=2.4.39
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/ \
	ftp://sunsite.cnlab-switch.ch/mirror/OpenLDAP/openldap-release/ \
	ftp://ftp.nl.uu.net/pub/unix/db/openldap/openldap-release/ \
	ftp://ftp.plig.org/pub/OpenLDAP/openldap-release/
PKG_MD5SUM:=b0d5ee4b252c841dec6b332d679cf943

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/openldap/Default
  TITLE:=LDAP implementation
  URL:=http://www.openldap.org/
  MAINTAINER:=W. Michael Petullo <mike@flyn.org>
endef

define Package/openldap/Default/description
	OpenLDAP Software is an open source implementation of the
	Lightweight Directory Access Protocol (LDAP).
endef

define Package/libopenldap
  $(call Package/openldap/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libopenssl +libsasl2 +libpthread
  TITLE+= (libraries)
endef

define Package/libopenldap/description
	$(call Package/openldap/Default/description)
	This package contains the shared LDAP client libraries, needed by other programs.
endef

define Package/libopenldap/conffiles
/etc/openldap/ldap.conf
endef

define Package/openldap-utils
  $(call Package/openldap/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libopenldap
  TITLE+= (utilities)
endef

define Package/openldap-utils/description
	$(call Package/openldap/Default/description)
	This package contains client programs required to access LDAP servers.
endef

define Package/openldap-server
  $(call Package/openldap/Default)
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libopenldap +libuuid
  TITLE+= (server)
endef

define Package/openldap-server/description
	$(call Package/openldap/Default/description)
	This package contains server programs required to provide LDAP services.
endef

define Package/openldap-server/conffiles
/etc/openldap/slapd.conf
endef

TARGET_CFLAGS += $(FPIC) -lpthread

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-debug \
	--enable-dynamic \
	--enable-syslog \
	--disable-local \
	--disable-slurpd \
	--with-cyrus-sasl \
	--without-fetch \
	--with-threads \
	--with-tls \
	--with-yielding_select="yes" \
	--without-cyrus-sasl \
	--without-threads \
	--without-tls \
	--enable-null \
	--disable-bdb \
	--disable-hdb \
	--disable-monitor \
	--disable-relay

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		HOSTCC="$(HOSTCC)" \
		depend all install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/{lber,ldap}*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{lber,ldap}*.{a,so*} $(1)/usr/lib/
endef

define Package/libopenldap/install
	$(INSTALL_DIR) $(1)/etc/openldap
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/openldap/ldap.conf $(1)/etc/openldap/
	$(INSTALL_DIR) $(1)/usr/lib
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
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/openldap/schema/* $(1)/etc/openldap/schema/
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/openldap/slapd.conf $(1)/etc/openldap/
	$(INSTALL_DIR) $(1)/usr/sbin
	# XXX: OpenLDAP installs slapd into libexecdir, not sbindir:
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/slapd $(1)/usr/sbin/
	# XXX: switch default backend to ldif, since bdb is disabled
	$(SED) 's|^\(database\)\([ \t]\+\)bdb|\1\2ldif|g' \
	    -e 's|^\(index\)|#\1|g' \
	    $(1)/etc/openldap/slapd.conf
endef

$(eval $(call BuildPackage,libopenldap))
$(eval $(call BuildPackage,openldap-utils))
$(eval $(call BuildPackage,openldap-server))
