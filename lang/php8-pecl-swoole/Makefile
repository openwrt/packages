#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PECL_NAME:=swoole
PECL_LONGNAME:=Extended Swoole Support

PKG_VERSION:=5.1.3
PKG_RELEASE:=1
PKG_HASH:=8e96b4d4ecaeffba5c1e085b7c08001068226a3921e23002e1f7ee186b91fbd8

PKG_NAME:=php8-pecl-swoole
PKG_SOURCE:=$(PECL_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://pecl.php.net/get/

PKG_MAINTAINER:=biyu gong <bywayboy@qq.com>

PKG_LICENSE:=Apache2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=php8
PKG_BUILD_DIR:=$(BUILD_DIR)/pecl-php8/$(PECL_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../php8/pecl.mk

CONFIGURE_ARGS+= \
	--disable-brotli \
	--enable-static=no

ifneq ($(SDK)$(CONFIG_PACKAGE_php8-mod-sockets),)
  CONFIGURE_ARGS+= --enable-sockets=shared
else
  CONFIGURE_ARGS+= --disable-sockets
endif


ifneq ($(SDK)$(PACKAGE_php8-mod-openssl),)
	CONFIGURE_ARGS += --enable-openssl
else
	CONFIGURE_ARGS += --disable-openssl
endif

ifneq ($(SDK)$(PACKAGE_php8-mod-mysqlnd),)
	CONFIGURE_ARGS += --enable-mysqlnd=shared
else
	CONFIGURE_ARGS += --disable-mysqlnd
endif

ifneq ($(SDK)$(PACKAGE_php8-mod-curl),)
	CONFIGURE_ARGS += --enable-swoole-curl=shared
endif

ifneq ($(SDK)$(CONFIG_PACKAGE_php8-mod-sqlite3),)
	CONFIGURE_ARGS+= --enable-swoole-sqlite
else
  CONFIGURE_ARGS+= --disable-swoole-sqlite
endif

$(eval $(call PHP8PECLPackage,swoole,$(PECL_LONGNAME),+libstdcpp,30))
$(eval $(call BuildPackage,$(PKG_NAME)))
