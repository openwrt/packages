#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PECL_NAME:=krb5
PECL_LONGNAME:=Bindings for the Kerberos library

PKG_VERSION:=1.1.2
PKG_RELEASE:=1
PKG_HASH:=3301e047fc7dc3574da19b2a4b18e15feca5ad39db9335c3353a8e16b855c35b

PKG_NAME:=php7-pecl-krb5
PKG_SOURCE:=$(PECL_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://pecl.php.net/get/

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=BSD
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=php7
PKG_BUILD_DIR:=$(BUILD_DIR)/pecl-php7/$(PECL_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../php7/pecl.mk

CONFIGURE_ARGS+= --with-krb5=shared,"$(STAGING_DIR)/usr"

$(eval $(call PECLPackage,krb5,$(PECL_LONGNAME),+krb5-libs,30))
$(eval $(call BuildPackage,$(PKG_NAME)))
