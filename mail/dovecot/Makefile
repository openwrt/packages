#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dovecot
PKG_VERSION:=2.2.35
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.dovecot.org/releases/2.2
PKG_HASH:=cce15db2fc5233386b63a3cf21c465c09e6e55014ed66c4f184b7d221a47180c
PKG_LICENSE:=LGPL-2.1 MIT BSD-3-Clause Unique
PKG_LICENSE_FILES:=COPYING COPYING.LGPL COPYING.MIT
PKG_MAINTAINER:=Lucian Cristian <lucian.cristian@gmail.com>

PKG_BUILD_DEPENDS:=libiconv
PKG_CONFIG_DEPENDS:= \
	CONFIG_DOVECOT_LDAP \
	CONFIG_DOVECOT_MYSQL \
	CONFIG_DOVECOT_PGSQL \
	CONFIG_DOVECOT_SQLITE \
	CONFIG_DOVECOT_ICU

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/dovecot
  SECTION:=mail
  CATEGORY:=Mail
  DEPENDS:=+DOVECOT_LDAP:libopenldap +DOVECOT_MYSQL:libmysqlclient +DOVECOT_PGSQL:libpq +DOVECOT_SQLITE:libsqlite3 +libopenssl +librt +zlib +libbz2 +libcap +DOVECOT_ICU:icu
  TITLE:=An IMAP and POP3 daemon
  URL:=http://www.dovecot.org/
  USERID:=dovecot=59:dovecot=59
  ABI_VERSION:=$(PKG_VERSION)
endef

define Package/dovecot/description
 Dovecot is a program which provides POP3 and IMAP services.
endef

define Package/dovecot/config
        menu "Select dovecot build options"
                depends on PACKAGE_dovecot
                config DOVECOT_LDAP
                        bool "LDAP support"
                        default n
                        help
                          Implements LDAP support in dovecot.
                config DOVECOT_MYSQL
                        bool "MYSQL support"
                        default n
                        help
                          Implements MYSQL support in dovecot.
                config DOVECOT_PGSQL
                        bool "PostgreSQL support"
                        default n
                        help
                          Implements PostgreSQL support in dovecot.
                config DOVECOT_SQLITE
                        bool "SQLite support"
                        default n
                        help
                          Implements SQLite DB support in dovecot.
                config DOVECOT_ICU
                        bool "Enable i18n features"
                        default n
                        help
                          Enable ICU (International Components for Unicode) support.
        endmenu
endef

define Package/dovecot/conffiles
/etc/init.d/dovecot
/etc/dovecot/
endef

define Package/dovecot-utils
  SECTION:=mail
  CATEGORY:=Mail
  DEPENDS:=+dovecot
  TITLE:=doveadm and dsync utilities for Dovecot
endef

CONFIGURE_ARGS += \
	--without-gssapi \
	--without-pam \
	--with-moduledir=/usr/lib/dovecot/modules \
	--with-notify=dnotify \
	--without-lzma \
	--without-lz4 \
	$(if $(CONFIG_DOVECOT_LDAP),--with-ldap=yes,--with-ldap=no) \
	$(if $(CONFIG_DOVECOT_MYSQL),--with-mysql=yes,--with-mysql=no) \
	$(if $(CONFIG_DOVECOT_PGSQL),--with-pgsql=yes,--with-pgsql=no) \
	$(if $(CONFIG_DOVECOT_SQLITE),--with-sqlite=yes,--with-sqlite=no) \
	$(if $(CONFIG_DOVECOT_ICU),--with-icu=yes,--with-icu=no)

CONFIGURE_VARS += \
	RPCGEN= \
	i_cv_signed_size_t=no \
	i_cv_signed_time_t=no \
	i_cv_gmtime_max_time_t=32 \
	i_cv_mmap_plays_with_write=yes \
	i_cv_fd_passing=yes \
	i_cv_c99_vsnprintf=yes \
	lib_cv_va_copy=yes \
	lib_cv_va_copy=yes \
	lib_cv___va_copy=yes \
	lib_cv_va_val_copy=yes

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/dovecot $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/dovecot $(1)/usr/lib/
	rm -f $(1)/usr/lib/dovecot/*.la
endef


define Package/dovecot/install
	$(INSTALL_DIR)  $(1)/etc/init.d \
			$(1)/etc/dovecot \
			$(1)/usr/share/doc/dovecot \
			$(1)/usr/lib/dovecot \
			$(1)/usr/bin \
			$(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/etc/dovecot/* $(1)/etc/dovecot/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/dovecot/* $(1)/usr/lib/dovecot/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/doc/dovecot/example-config $(1)/usr/share/doc/dovecot/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/doveconf $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/dovecot.init $(1)/etc/init.d/dovecot
	rm  $(1)/usr/lib/dovecot/dovecot-config
	find $(1)/usr/lib/dovecot/ -name "*.a" -o -name "*.la" | xargs rm
endef

define Package/dovecot-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/doveadm $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/dsync $(1)/usr/bin/
endef

$(eval $(call BuildPackage,dovecot))
$(eval $(call BuildPackage,dovecot-utils))
