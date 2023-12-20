#
# Copyright (C) 2007-2023 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libcurl-gnutls

PKG_SOURCE_NAME:=curl
PKG_VERSION:=8.5.0
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/curl/curl/releases/download/curl-$(subst .,_,$(PKG_VERSION))/ \
	https://dl.uxnr.de/mirror/curl/ \
	https://curl.askapache.com/download/ \
	https://curl.se/download/
PKG_HASH:=ce4b6a6655431147624aaf582632a36fe1ade262d5fab385c60f78942dd8d87b

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:haxx:libcurl
PKG_ABI_VERSION:=4

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

# Make sure headers are present for packages using libcurl-gnutls
PKG_BUILD_DEPENDS:=curl

include $(INCLUDE_DIR)/package.mk

define Package/libcurl-gnutls
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=https://gnunet.org/en/gnurl.html
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libgnutls +libidn2 +zlib
  TITLE:=A client-side HTTP/HTTPS transfer library (build against gnuTLS)
  ABI_VERSION:=$(PKG_ABI_VERSION)
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	$(call autoconf_bool,CONFIG_IPV6,ipv6) \
	--with-gnutls="$(STAGING_DIR)/usr" \
	--with-libidn="$(STAGING_DIR)/usr" \
	--with-zlib="$(STAGING_DIR)/usr" \
	--with-ca-path="/etc/ssl/certs/" \
	--enable-shared \
	--enable-static \
	--without-axtls \
	--without-brotli \
	--without-libssh2 \
	--without-winidn \
	--without-librtmp \
	--without-nghttp2 \
	--without-nss \
	--without-cyassl \
	--without-libpsl \
	--without-polarssl \
	--without-openssl \
	--without-winssl \
	--without-zstd \
	--disable-ares \
	--disable-sspi \
	--disable-crypto-auth \
	--disable-ntlm-wb \
	--disable-tls-srp \
	--disable-ldap \
	--disable-ldaps \
	--disable-mqtt \
	--disable-rtsp \
	--disable-dict \
	--disable-telnet \
	--disable-tftp \
	--disable-pop3 \
	--disable-imap \
	--disable-smtp \
	--disable-gopher \
	--disable-file \
	--disable-ftp \
	--disable-smb \
	--disable-debug \
	--disable-manual \
	--disable-verbose

define Build/Compile
	$(call Build/Compile/Default)
	patchelf --set-soname 'libcurl-gnutls.so.$(PKG_ABI_VERSION)' $(PKG_BUILD_DIR)/lib/.libs/libcurl.so.$(PKG_ABI_VERSION).*
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcurl.so.$(PKG_ABI_VERSION).* $(1)/usr/lib/libcurl-gnutls.so.$(PKG_ABI_VERSION)
	$(LN) libcurl-gnutls.so.$(PKG_ABI_VERSION) $(1)/usr/lib/libcurl-gnutls.so
endef

define Package/libcurl-gnutls/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcurl.so.$(PKG_ABI_VERSION).* $(1)/usr/lib/libcurl-gnutls.so.$(PKG_ABI_VERSION)
	$(LN) libcurl-gnutls.so.$(PKG_ABI_VERSION) $(1)/usr/lib/libcurl-gnutls.so
endef

$(eval $(call BuildPackage,libcurl-gnutls))
