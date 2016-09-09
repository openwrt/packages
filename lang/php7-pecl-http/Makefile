#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PECL_NAME:=pecl_http
PECL_LONGNAME:=Extended HTTP Support

PKG_VERSION:=3.0.1
PKG_RELEASE:=2
PKG_MD5SUM:=042c97314c180f6473338f0c5d35fabd

PKG_NAME:=php7-pecl-http
PKG_SOURCE:=$(PECL_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://pecl.php.net/get/

PKG_MAINTAINER:=Michael Heimpold <mhei@heimpold.de>

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=php7 php7-pecl-propro php7-pecl-raphf
PKG_BUILD_DIR:=$(BUILD_DIR)/pecl-php7/$(PECL_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../php7/pecl.mk

CONFIGURE_VARS+= \
	PHP_PROPRO=yes \
	PHP_RAPHF=yes \

CONFIGURE_ARGS+= \
	--with-http \
	--without-http-shared-deps \
	--with-http-libcurl-dir="$(STAGING_DIR)/usr" \
	--with-http-libevent-dir="$(STAGING_DIR)/usr" \
	--with-http-libidn-dir="$(STAGING_DIR)/usr"

$(eval $(call PECLPackage,http,$(PECL_LONGNAME),+libcurl +librt +libevent2 +libidn +php7-mod-iconv +php7-mod-session +php7-pecl-raphf +php7-pecl-propro,30))
$(eval $(call BuildPackage,$(PKG_NAME)))
