#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PECL_NAME:=mcrypt
PECL_LONGNAME:=Bindings for the libmcrypt library

PKG_VERSION:=1.0.2
PKG_RELEASE:=1
PKG_HASH:=4d21dd20bfdc3cf4d43c967abdd137224f9c56258ca28ee0bc66ce130e01cae4

PKG_NAME:=php7-pecl-mcrypt
PKG_SOURCE:=$(PECL_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://pecl.php.net/get/

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=PHPv3.01
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=php7
PKG_BUILD_DIR:=$(BUILD_DIR)/pecl-php7/$(PECL_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../php7/pecl.mk

CONFIGURE_ARGS+= --with-mcrypt=shared,"$(STAGING_DIR)/usr"

$(eval $(call PECLPackage,mcrypt,$(PECL_LONGNAME),+libmcrypt +libltdl,30))
$(eval $(call BuildPackage,$(PKG_NAME)))
