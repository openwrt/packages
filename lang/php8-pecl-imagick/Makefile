#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PECL_NAME:=imagick
PECL_LONGNAME:=Image Processing (ImageMagick binding)

PKG_VERSION:=3.7.0
PKG_RELEASE:=2
PKG_HASH:=5a364354109029d224bcbb2e82e15b248be9b641227f45e63425c06531792d3e

PKG_NAME:=php8-pecl-imagick
PKG_SOURCE:=$(PECL_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=https://pecl.php.net/get/

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=PHP-3.01
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:php:imagick

PKG_BUILD_DEPENDS:=php8
PKG_BUILD_DIR:=$(BUILD_DIR)/pecl-php8/$(PECL_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../php8/pecl.mk

CONFIGURE_ARGS+= --with-imagick="$(STAGING_DIR)/usr"

$(eval $(call PHP8PECLPackage,imagick,$(PECL_LONGNAME),+imagemagick,30))
$(eval $(call BuildPackage,$(PKG_NAME)))
