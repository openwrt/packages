#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=spi-tools
PKG_VERSION:=1

PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cpb-/spi-tools.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=cc6a41fdcec60610703ba6db488c621c64952898
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=3c37fde79ab09e9a590f4cdb55751083017197d0037a7c0dce56fceef5e05a21

PKG_MAINTAINER:=John Crispin <blogic@openwrt.org>

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/spi-tools
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Command line SPI tools
endef

EXTRA_CFLAGS+=-DVERSION=\"$(PKG_SOURCE_VERSION)\"

define Build/Compile
	cd $(PKG_BUILD_DIR) ; \
        $(TARGET_CC) $(TARGET_CFLAGS) $(EXTRA_CFLAGS) -Wall -Werror -o spi-config src/spi-config.c ; \
        $(TARGET_CC) $(TARGET_CFLAGS) $(EXTRA_CFLAGS) -Wall -Werror -o spi-pipe src/spi-pipe.c
endef

define Package/spi-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/spi-config $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/spi-pipe $(1)/usr/bin
endef

$(eval $(call BuildPackage,spi-tools))
