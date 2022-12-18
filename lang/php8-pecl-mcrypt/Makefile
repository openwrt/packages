#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PECL_NAME:=mcrypt
PECL_LONGNAME:=Bindings for the libmcrypt library

PKG_VERSION:=1.0.5
PKG_RELEASE:=1
PKG_HASH:=c9f51e211640a15d2a983f5d80e26660656351651d6f682d657bdf1cfa07d8a3

PKG_NAME:=php8-pecl-mcrypt
PKG_SOURCE:=$(PECL_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://pecl.php.net/get/

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=PHP-3.01
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=php8
PKG_BUILD_DIR:=$(BUILD_DIR)/pecl-php8/$(PECL_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../php8/pecl.mk

CONFIGURE_ARGS+= --with-mcrypt=shared,"$(STAGING_DIR)/usr"

$(eval $(call PHP8PECLPackage,mcrypt,$(PECL_LONGNAME),+libmcrypt +libltdl,30))
$(eval $(call BuildPackage,$(PKG_NAME)))
