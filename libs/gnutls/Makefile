#
# Copyright (C) 2005-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gnutls
PKG_VERSION:=3.5.19
PKG_RELEASE:=1
PKG_USE_MIPS16:=0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.gnupg.org/ftp/gcrypt/gnutls/v3.5
PKG_HASH:=1936eb64f03aaefd6eb16cef0567457777618573826b94d03376bb6a4afadc44
#PKG_FIXUP:=autoreconf gettext-version
PKG_MAINTAINER:=Nikos Mavrogiannopoulos <nmav@gnutls.org>
PKG_LICENSE:=LGPLv2.1+

PKG_INSTALL:=1
PKG_LIBTOOL_PATHS:=. lib
PKG_CHECK_FORMAT_SECURITY:=0

PKG_CONFIG_DEPENDS:= \
	CONFIG_GNUTLS_ALPN \
	CONFIG_GNUTLS_ANON \
	CONFIG_GNUTLS_CRYPTODEV \
	CONFIG_GNUTLS_DTLS_SRTP \
	CONFIG_GNUTLS_EXT_LIBTASN1 \
	CONFIG_GNUTLS_HEARTBEAT \
	CONFIG_GNUTLS_OCSP \
	CONFIG_GNUTLS_OPENPGP \
	CONFIG_GNUTLS_PKCS11 \
	CONFIG_GNUTLS_PSK \
	CONFIG_GNUTLS_SRP \
	CONFIG_GNUTLS_TPM \
	CONFIG_LIBNETTLE_MINI \

include $(INCLUDE_DIR)/package.mk


define Package/gnutls/Default
  SUBMENU:=SSL
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GNU TLS
  URL:=http://www.gnutls.org/
endef

define Package/gnutls/Default/description
 GnuTLS is a secure communications library implementing the SSL, TLS
 and DTLS protocols and technologies around them. It provides a simple
 C language application programming interface (API) to access the secure
 communications protocols as well as APIs to parse and write X.509, PKCS12,
 OpenPGP and other required structures. It is aimed to be portable and
 efficient with focus on security and interoperability.
endef


define Package/certtool
$(call Package/gnutls/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Encryption
  TITLE+= (certool utility)
  DEPENDS+= +libgnutls
endef

define Package/certtool/description
$(call Package/gnutls/Default/description)
 This package contains the GnuTLS certtool utility.
endef


define Package/gnutls-utils
$(call Package/gnutls/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Encryption
  TITLE+= (utilities)
  DEPENDS+= +libgnutls
endef

define Package/gnutls-utils/description
$(call Package/gnutls/Default/description)
 This package contains the GnuTLS gnutls-cli, gnutls-serv, psktool,
 and srptool utilities.
endef

define Package/libgnutls/config
	source "$(SOURCE)/Config.in"
endef

define Package/libgnutls
$(call Package/gnutls/Default)
  TITLE+= (library)
  DEPENDS+= +libnettle +!LIBNETTLE_MINI:libgmp +GNUTLS_EXT_LIBTASN1:libtasn1 +GNUTLS_PKCS11:p11-kit +GNUTLS_CRYPTODEV:kmod-cryptodev
endef

define Package/libgnutls/description
$(call Package/gnutls/Default/description)
 This package contains the GnuTLS shared library, needed by other programs.
endef


CONFIGURE_ARGS+= \
	--enable-shared \
	--enable-static \
	--disable-rpath \
	--disable-libdane \
	--with-included-unistring \
	--disable-guile \
	--disable-nls \
	--without-idn \
	--without-zlib \
	--enable-local-libopts \
	--disable-doc \
	--disable-tests \
	--with-default-trust-store-dir=/etc/ssl/certs/ \
	--disable-crywrap \
	--with-librt-prefix="$(LIBRT_ROOT_DIR)/"

ifneq ($(CONFIG_GNUTLS_EXT_LIBTASN1),y)
CONFIGURE_ARGS += --with-included-libtasn1
endif

ifneq ($(CONFIG_GNUTLS_PKCS11),y)
CONFIGURE_ARGS += --without-p11-kit
endif

ifeq ($(CONFIG_LIBNETTLE_MINI),y)
CONFIGURE_ARGS += --with-nettle-mini
endif

ifneq ($(CONFIG_GNUTLS_DTLS_SRTP),y)
CONFIGURE_ARGS += --disable-dtls-srtp-support
endif

ifneq ($(CONFIG_GNUTLS_ALPN),y)
CONFIGURE_ARGS += --disable-alpn-support
endif

ifneq ($(CONFIG_GNUTLS_HEARTBEAT),y)
CONFIGURE_ARGS += --disable-heartbeat-support
endif

ifneq ($(CONFIG_GNUTLS_SRP),y)
CONFIGURE_ARGS += --disable-srp-authentication
endif

ifneq ($(CONFIG_GNUTLS_PSK),y)
CONFIGURE_ARGS += --disable-psk-authentication
endif

ifneq ($(CONFIG_GNUTLS_OPENPGP),y)
CONFIGURE_ARGS += --disable-openpgp-authentication
endif

ifneq ($(CONFIG_GNUTLS_ANON),y)
CONFIGURE_ARGS += --disable-anon-authentication
endif

ifneq ($(CONFIG_GNUTLS_OCSP),y)
CONFIGURE_ARGS += --disable-ocsp
endif

ifneq ($(CONFIG_GNUTLS_TPM),y)
CONFIGURE_ARGS += --without-tpm
endif

ifeq ($(CONFIG_GNUTLS_CRYPTODEV),y)
CONFIGURE_ARGS += --enable-cryptodev
endif

TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libgnutls.so* \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/gnutls \
		$(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/gnutls.pc \
		$(1)/usr/lib/pkgconfig/
endef


define Package/certtool/conffiles
/etc/gnutls/certtool.cfg
endef

define Package/certtool/install
	$(INSTALL_DIR) $(1)/etc/gnutls
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/doc/certtool.cfg $(1)/etc/gnutls/
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/certtool $(1)/usr/bin/
endef


define Package/gnutls-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
ifeq ($(CONFIG_GNUTLS_OCSP),y)
ifeq ($(CONFIG_GNUTLS_ANON),y)
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/gnutls-{cli,serv} \
		$(1)/usr/bin/
endif
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/ocsptool \
		$(1)/usr/bin/
endif
ifeq ($(CONFIG_GNUTLS_SRP),y)
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/srptool \
		$(1)/usr/bin/
endif
ifeq ($(CONFIG_GNUTLS_PSK),y)
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/psktool \
		$(1)/usr/bin/
endif
ifeq ($(CONFIG_GNUTLS_PKCS11),y)
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/p11tool \
		$(1)/usr/bin/
endif
ifeq ($(CONFIG_GNUTLS_TPM),y)
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/tpmtool \
		$(1)/usr/bin/
endif
endef


define Package/libgnutls/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnutls.so.* $(1)/usr/lib/
endef


$(eval $(call BuildPackage,certtool))
$(eval $(call BuildPackage,gnutls-utils))
$(eval $(call BuildPackage,libgnutls))
