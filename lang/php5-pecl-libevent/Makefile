#
# Copyright (C) 2012-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PECL_NAME:=libevent
PECL_LONGNAME:=Libevent - event notification

PKG_VERSION:=0.1.0
PKG_RELEASE:=2
PKG_MD5SUM:=e091371a9e714098a4c04a6e3daeb56a

PKG_NAME:=php5-pecl-$(PECL_NAME)
PKG_SOURCE:=$(PECL_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://pecl.php.net/get/

PKG_MAINTAINER:=Michael Heimpold <mhei@heimpold.de>

PKG_LICENSE:=PHPv3.01
PKG_LICENSE_FILES:=

PKG_BUILD_DIR:=$(BUILD_DIR)/pecl-php5/$(PECL_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../php5/pecl.mk

CONFIGURE_ARGS+= --with-libevent=shared,"$(STAGING_DIR)/usr"

$(eval $(call PECLPackage,$(PECL_NAME),$(PECL_LONGNAME),+libevent2 +php5-mod-sockets))
$(eval $(call BuildPackage,$(PKG_NAME)))
