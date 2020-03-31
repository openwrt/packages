#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PECL_NAME:=krb5
PECL_LONGNAME:=Bindings for the Kerberos library

PKG_VERSION:=1.1.3
PKG_RELEASE:=1
PKG_HASH:=3a65bb5f7d64ed5f6fbcf07250c17b0de29f693ac88f96cd1cc9737b996da120

PKG_NAME:=php7-pecl-krb5
PKG_SOURCE:=$(PECL_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://pecl.php.net/get/

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=php7
PKG_BUILD_DIR:=$(BUILD_DIR)/pecl-php7/$(PECL_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../php7/pecl.mk

CONFIGURE_ARGS+= \
	--with-krb5=shared,"$(STAGING_DIR)/usr" \
	--with-krb5config=$(STAGING_DIR)/usr/bin/krb5-config

$(eval $(call PECLPackage,krb5,$(PECL_LONGNAME),+krb5-libs,30))
$(eval $(call BuildPackage,$(PKG_NAME)))
