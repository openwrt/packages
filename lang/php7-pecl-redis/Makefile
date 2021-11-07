#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PECL_NAME:=redis
PECL_LONGNAME:=PHP extension for interfacing with Redis

PKG_VERSION:=5.3.4
PKG_RELEASE:=1
PKG_HASH:=4b39056f3356f135255e059efd76398d1c7607c86bd52513e6341bb07a3fb4cc

PKG_NAME:=php7-pecl-redis
PKG_SOURCE:=$(PECL_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://pecl.php.net/get/

PKG_MAINTAINER:=Michael Heimpold <mhei@heimpold.de>

PKG_LICENSE:=PHP-3.01
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/pecl-php7/$(PECL_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../php7/pecl.mk

CONFIGURE_ARGS+= \
	--enable-redis \
	--enable-redis-json \
	--disable-redis-igbinary \
	--disable-redis-lzf \
	--disable-redis-msgpack

$(eval $(call PHP7PECLPackage,$(PECL_NAME),$(PECL_LONGNAME),+php7-mod-json +php7-mod-session,25))
$(eval $(call BuildPackage,$(PKG_NAME)))
