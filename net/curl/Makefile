#
# Copyright (C) 2007-2020 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/nls.mk

PKG_NAME:=curl
PKG_VERSION:=8.19.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/curl/curl/releases/download/curl-$(subst .,_,$(PKG_VERSION))/ \
	https://curl.se/download/
PKG_HASH:=4eb41489790d19e190d7ac7e18e82857cdd68af8f4e66b292ced562d333f11df

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:haxx:libcurl

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS:= \
  CONFIG_IPV6 \
  \
  CONFIG_LIBCURL_WOLFSSL \
  CONFIG_LIBCURL_GNUTLS \
  CONFIG_LIBCURL_OPENSSL \
  CONFIG_LIBCURL_MBEDTLS \
  CONFIG_LIBCURL_NOSSL \
  \
  CONFIG_LIBCURL_LIBIDN2 \
  CONFIG_LIBCURL_SSH2 \
  CONFIG_LIBCURL_ZLIB \
  CONFIG_LIBCURL_ZSTD \
  \
  CONFIG_LIBCURL_DICT \
  CONFIG_LIBCURL_FILE \
  CONFIG_LIBCURL_FTP \
  CONFIG_LIBCURL_GOPHER \
  CONFIG_LIBCURL_HTTP \
  CONFIG_LIBCURL_WEBSOCKETS \
  CONFIG_LIBCURL_IMAP \
  CONFIG_LIBCURL_LDAP \
  CONFIG_LIBCURL_LDAPS \
  CONFIG_LIBCURL_POP3 \
  CONFIG_LIBCURL_RTSP \
  CONFIG_LIBCURL_SMB \
  CONFIG_LIBCURL_SMTP \
  CONFIG_LIBCURL_TELNET \
  CONFIG_LIBCURL_TFTP \
  CONFIG_LIBCURL_HTTP2 \
  CONFIG_LIBCURL_HTTP3 \
  \
  CONFIG_LIBCURL_COOKIES \
  CONFIG_LIBCURL_CRYPTO_AUTH \
  CONFIG_LIBCURL_HTTP_AUTH \
  CONFIG_LIBCURL_LIBCURL_OPTION \
  CONFIG_LIBCURL_PROXY \
  CONFIG_LIBCURL_THREADED_RESOLVER \
  CONFIG_LIBCURL_TLS_SRP \
  CONFIG_LIBCURL_UNIX_SOCKETS \
  CONFIG_LIBCURL_VERBOSE \
  CONFIG_LIBCURL_NTLM \
  $(if $(filter openssl,$(BUILD_VARIANT)), \
	CONFIG_OPENSSL_ENGINE \
	CONFIG_OPENSSL_WITH_COMPRESSION \
	CONFIG_OPENSSL_WITH_NPN)

include $(INCLUDE_DIR)/package.mk

define Package/curl
  SECTION:=net
  CATEGORY:=Network
  URL:=https://curl.se/
  MAINTAINER:=
  SUBMENU:=File Transfer
  DEPENDS:=+libcurl
  TITLE:=A client-side URL transfer utility
endef

define Package/libcurl/Default
  SECTION:=libs
  CATEGORY:=Libraries
  MAINTAINER:=
  DEPENDS:= +LIBCURL_ZLIB:zlib \
            +LIBCURL_ZSTD:libzstd \
            +LIBCURL_THREADED_RESOLVER:libpthread \
            +LIBCURL_LDAP:libopenldap \
            +LIBCURL_LIBIDN2:libidn2 \
            +LIBCURL_SSH2:libssh2 \
            +LIBCURL_HTTP2:libnghttp2 \
            +ca-bundle
  TITLE:=A client-side URL transfer library
  MENU:=1
  ABI_VERSION:=4
endef

define Package/libcurl-nossl
  $(call Package/libcurl/Default)
  PROVIDES:=libcurl
  VARIANT:=nossl
  TITLE+= (No SSL)
endef

define Package/libcurl-nossl/config
  if PACKAGE_libcurl-nossl
    source "$(SOURCE)/Config.in"
  endif
endef

define Package/libcurl-wolfssl
  $(call Package/libcurl/Default)
  DEPENDS+= +libwolfssl
  PROVIDES:=libcurl
  VARIANT:=wolfssl
  TITLE+= (wolfSSL)
endef

define Package/libcurl-wolfssl/config
  if PACKAGE_libcurl-wolfssl
    source "$(SOURCE)/Config.in"
  endif
endef

define Package/libcurl-gnutls
  $(call Package/libcurl/Default)
  DEPENDS+= +libgnutls
  PROVIDES:=libcurl
  VARIANT:=gnutls
  TITLE+= (GnuTLS)
endef

define Package/libcurl-gnutls/config
  if PACKAGE_libcurl-gnutls
    source "$(SOURCE)/Config.in"
  endif
endef

define Package/libcurl-openssl
  $(call Package/libcurl/Default)
  DEPENDS+= +libopenssl +LIBCURL_HTTP3:libnghttp3 +LIBCURL_HTTP3:libngtcp2
  PROVIDES:=libcurl
  VARIANT:=openssl
  TITLE+= (OpenSSL)
endef

define Package/libcurl-openssl/config
  if PACKAGE_libcurl-openssl
    source "$(SOURCE)/Config.in"
  endif
endef

define Package/libcurl-mbedtls
  $(call Package/libcurl/Default)
  DEPENDS+= +libmbedtls
  PROVIDES:=libcurl
  VARIANT:=mbedtls
  DEFAULT_VARIANT:=1
  TITLE+= (mbedTLS)
endef

define Package/libcurl-mbedtls/config
  if PACKAGE_libcurl-mbedtls
    source "$(SOURCE)/Config.in"
  endif
endef

LIBCURL_WITH_HTTP3 := $(if $(filter openssl,$(BUILD_VARIANT)),$(CONFIG_LIBCURL_HTTP3))
LIBCURL_WITH_LDAPS := $(if $(filter-out nossl,$(BUILD_VARIANT)),$(CONFIG_LIBCURL_LDAPS))
LIBCURL_WITH_SMB := $(if $(filter gnutls openssl,$(BUILD_VARIANT)),$(CONFIG_LIBCURL_SMB))
LIBCURL_WITH_NTLM := $(if $(filter-out nossl,$(BUILD_VARIANT)),$(CONFIG_LIBCURL_NTLM))

TARGET_CFLAGS += $(FPIC)
TARGET_CPPFLAGS += $(if $(LIBCURL_WITH_NTLM),,-DCURL_DISABLE_NTLM)
TARGET_LDFLAGS += -Wl,--gc-sections

CONFIGURE_ARGS += \
	--disable-debug \
	--disable-docs \
	--disable-manual \
	--disable-ares \
	--disable-ipfs \
	--enable-shared \
	--enable-static \
	--without-nss \
	--without-librtmp \
	--without-ca-path \
	--without-libpsl \
	--without-zstd \
	--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt \
	\
	$(call autoconf_bool,CONFIG_IPV6,ipv6) \
	\
	$(if $(filter nossl,$(BUILD_VARIANT)),--without-ssl) \
	$(if $(filter wolfssl,$(BUILD_VARIANT)),--with-wolfssl="$(STAGING_DIR)/usr",--without-wolfssl) \
	$(if $(filter gnutls,$(BUILD_VARIANT)),--with-gnutls="$(STAGING_DIR)/usr",--without-gnutls) \
	$(if $(filter openssl,$(BUILD_VARIANT)),--with-openssl="$(STAGING_DIR)/usr",--without-openssl) \
	$(if $(filter mbedtls,$(BUILD_VARIANT)),--with-mbedtls="$(STAGING_DIR)/usr",--without-mbedtls) \
	\
	$(if $(CONFIG_LIBCURL_LIBIDN2),--with-libidn2="$(STAGING_DIR)/usr",--without-libidn2) \
	$(if $(CONFIG_LIBCURL_SSH2),--with-libssh2="$(STAGING_DIR)/usr",--without-libssh2) \
	$(if $(CONFIG_LIBCURL_ZLIB),--with-zlib="$(STAGING_DIR)/usr",--without-zlib) \
	$(if $(CONFIG_LIBCURL_ZSTD),--with-zstd="$(STAGING_DIR)/usr",--without-zstd) \
	$(if $(CONFIG_LIBCURL_HTTP2),--with-nghttp2="$(STAGING_DIR)/usr",--without-nghttp2) \
	$(if $(LIBCURL_WITH_HTTP3),--with-nghttp3="$(STAGING_DIR)/usr" --with-ngtcp2="$(STAGING_DIR)/usr",--without-nghttp3 --without-ngtcp2) \
	\
	$(call autoconf_bool,CONFIG_LIBCURL_DICT,dict) \
	$(call autoconf_bool,CONFIG_LIBCURL_FILE,file) \
	$(call autoconf_bool,CONFIG_LIBCURL_FTP,ftp) \
	$(call autoconf_bool,CONFIG_LIBCURL_GOPHER,gopher) \
	$(call autoconf_bool,CONFIG_LIBCURL_HTTP,http) \
	$(call autoconf_bool,CONFIG_LIBCURL_IMAP,imap) \
	$(call autoconf_bool,CONFIG_LIBCURL_LDAP,ldap) \
	$(call autoconf_bool,LIBCURL_WITH_LDAPS,ldaps) \
	$(call autoconf_bool,CONFIG_LIBCURL_POP3,pop3) \
	$(call autoconf_bool,CONFIG_LIBCURL_RTSP,rtsp) \
	$(call autoconf_bool,LIBCURL_WITH_SMB,smb) \
	$(call autoconf_bool,CONFIG_LIBCURL_SMTP,smtp) \
	$(call autoconf_bool,CONFIG_LIBCURL_TELNET,telnet) \
	$(call autoconf_bool,CONFIG_LIBCURL_TFTP,tftp) \
	$(call autoconf_bool,CONFIG_LIBCURL_WEBSOCKETS,websockets) \
	\
	$(call autoconf_bool,CONFIG_LIBCURL_COOKIES,cookies) \
	$(call autoconf_bool,CONFIG_LIBCURL_CRYPTO_AUTH,crypto-auth) \
	$(call autoconf_bool,CONFIG_LIBCURL_HTTP_AUTH,http-auth) \
	$(call autoconf_bool,CONFIG_LIBCURL_LIBCURL_OPTION,libcurl-option) \
	$(call autoconf_bool,CONFIG_LIBCURL_PROXY,proxy) \
	$(call autoconf_bool,CONFIG_LIBCURL_THREADED_RESOLVER,threaded-resolver) \
	$(call autoconf_bool,CONFIG_LIBCURL_TLS_SRP,tls-srp) \
	$(call autoconf_bool,CONFIG_LIBCURL_UNIX_SOCKETS,unix-sockets) \
	$(call autoconf_bool,CONFIG_LIBCURL_VERBOSE,verbose) \

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin $(1)/usr/bin $(1)/usr/include $(1)/usr/lib $(1)/usr/lib/pkgconfig
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/curl-config $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/curl $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcurl.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libcurl.pc $(1)/usr/lib/pkgconfig/
	$(SED) 's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' $(1)/usr/bin/curl-config
	[ -n "$(TARGET_LDFLAGS)" ] && $(SED) 's#$(TARGET_LDFLAGS)##g' $(1)/usr/lib/pkgconfig/libcurl.pc || true
	$(LN) $(STAGING_DIR)/usr/bin/curl-config $(2)/bin/
endef

define Package/curl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/curl $(1)/usr/bin/
endef

define Package/libcurl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcurl.so.* $(1)/usr/lib/
endef

Package/libcurl-nossl/install = $(Package/libcurl/install)
Package/libcurl-wolfssl/install = $(Package/libcurl/install)
Package/libcurl-gnutls/install = $(Package/libcurl/install)
Package/libcurl-openssl/install = $(Package/libcurl/install)
Package/libcurl-mbedtls/install = $(Package/libcurl/install)

$(eval $(call BuildPackage,libcurl-nossl))
$(eval $(call BuildPackage,libcurl-wolfssl))
$(eval $(call BuildPackage,libcurl-gnutls))
$(eval $(call BuildPackage,libcurl-openssl))
$(eval $(call BuildPackage,libcurl-mbedtls))
$(eval $(call BuildPackage,curl))
