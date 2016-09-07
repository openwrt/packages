#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PECL_NAME:=libevent
PECL_LONGNAME:=Libevent - event notification

PKG_NAME:=php7-pecl-$(PECL_NAME)
PKG_VERSION=2016-08-30-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/expressif/pecl-event-libevent.git
PKG_SOURCE_VERSION:=9e72744ce6224beafc7b54ce2a3a990f1c552a5a
PKG_SOURCE_SUBDIR:=$(PECL_NAME)-$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PECL_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_MAINTAINER:=Michael Heimpold <mhei@heimpold.de>

PKG_LICENSE:=PHPv3.01
PKG_LICENSE_FILES:=

PKG_BUILD_DIR:=$(BUILD_DIR)/pecl-php7/$(PECL_NAME)-$(PKG_SOURCE_VERSION)
PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../php7/pecl.mk

CONFIGURE_ARGS+= --with-libevent=shared,"$(STAGING_DIR)/usr"

$(eval $(call PECLPackage,$(PECL_NAME),$(PECL_LONGNAME),+libevent2 +php7-mod-sockets,25))
$(eval $(call BuildPackage,$(PKG_NAME)))
