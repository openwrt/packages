#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PECL_NAME:=pecl_http
PECL_LONGNAME:=Extended HTTP Support

PKG_VERSION:=4.2.4
PKG_RELEASE:=1
PKG_HASH:=fb1e10c2e5edfb011ff8dc2e473cdbd2bbe0127d1279dfce4d98570555ac6ded

PKG_NAME:=php8-pecl-http
PKG_SOURCE:=$(PECL_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://pecl.php.net/get/

PKG_MAINTAINER:=Michael Heimpold <mhei@heimpold.de>

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=php8 php8-pecl-raphf
PKG_BUILD_DIR:=$(BUILD_DIR)/pecl-php8/$(PECL_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../php8/pecl.mk

CONFIGURE_VARS+= \
	PECL_cv_HAVE_EXT_raphf=yes \
	PECL_cv_HAVE_LIBCURL_ARES=no \
	PECL_cv_HAVE_LIBCURL_OpenSSL=$(if $(CONFIG_LIBCURL_OPENSSL),yes,no) \
	PECL_cv_HAVE_LIBCURL_GnuTLS=$(if $(CONFIG_LIBCURL_GNUTLS),yes,no) \
	PECL_cv_HAVE_LIBCURL_NSS=no \
	PECL_cv_HAVE_LIBCURL_SecureTransport=no \
	PECL_cv_HAVE_LIBCURL_GSKit=no \
	PECL_cv_HAVE_LIBCURL_PolarSSL=no \
	PECL_cv_HAVE_LIBCURL_WolfSSL=$(if $(CONFIG_LIBCURL_WOLFSSL),yes,no) \
	PECL_cv_HAVE_LIBCURL_mbedTLS=$(if $(CONFIG_LIBCURL_MBEDTLS),yes,no) \
	PECL_cv_HAVE_LIBCURL_axTLS=no \
	PECL_cv_LIBCURL_TLSAUTH_SRP=$(if $(CONFIG_LIBCURL_TLS_SRP),yes,no) \
	PECL_cv_LIBCURL_SHARE_SSL=yes \
	PECL_cv_LIBCURL_TLS13_CIPHERS=$(if $(CONFIG_OPENSSL_WITH_TLS13),yes,no) \

CONFIGURE_ARGS+= \
	--with-http \
	--without-http-shared-deps \
	--with-http-zlib-dir="$(STAGING_DIR)/usr" \
	--with-http-libcurl-dir="$(STAGING_DIR)/usr" \
	--with-http-libevent-dir="$(STAGING_DIR)/usr" \
	--with-http-libidn-dir="$(STAGING_DIR)/usr" \
	--with-http-libidnkit-dir=no \
	--with-http-libidnkit2-dir=no

$(eval $(call PHP8PECLPackage,http,$(PECL_LONGNAME),+icu +libcurl +librt +libevent2 +PACKAGE_libidn:libidn +libidn2 +php8-mod-iconv +php8-mod-session +php8-pecl-raphf,30))
$(eval $(call BuildPackage,$(PKG_NAME)))
