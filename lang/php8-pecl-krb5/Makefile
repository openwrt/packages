#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PECL_NAME:=krb5
PECL_LONGNAME:=Bindings for the Kerberos library

PKG_VERSION:=1.1.5
PKG_RELEASE:=1
PKG_HASH:=2798e57ad231aa3467f09460e3e69169e04c88bd82972d8e86a6641e4ddc9d3d

PKG_NAME:=php8-pecl-krb5
PKG_SOURCE:=$(PECL_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=https://pecl.php.net/get/

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=php8
PKG_BUILD_DIR:=$(BUILD_DIR)/pecl-php8/$(PECL_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../php8/pecl.mk

CONFIGURE_ARGS+= \
	--with-krb5=shared,"$(STAGING_DIR)/usr" \
	--with-krb5config=$(STAGING_DIR)/usr/bin/krb5-config

$(eval $(call PHP8PECLPackage,krb5,$(PECL_LONGNAME),+krb5-libs,30))
$(eval $(call BuildPackage,$(PKG_NAME)))
