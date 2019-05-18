#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PECL_NAME:=redis
PECL_LONGNAME:=PHP extension for interfacing with Redis

PKG_VERSION:=4.3.0
PKG_RELEASE:=1
PKG_HASH:=c0f04cec349960a842b60920fb8a433656e2e494eaed6e663397d67102a51ba2

PKG_NAME:=php7-pecl-redis
PKG_SOURCE:=$(PECL_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://pecl.php.net/get/

PKG_MAINTAINER:=Michael Heimpold <mhei@heimpold.de>

PKG_LICENSE:=PHPv3.01
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/pecl-php7/$(PECL_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../php7/pecl.mk

CONFIGURE_ARGS+= \
	--enable-redis \
	--disable-redis-igbinary \
	--disable-redis-lzf

$(eval $(call PECLPackage,$(PECL_NAME),$(PECL_LONGNAME),+php7-mod-hash +php7-mod-session,25))
$(eval $(call BuildPackage,$(PKG_NAME)))
