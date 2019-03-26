#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=spi-tools
PKG_VERSION:=0.8.3
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://codeload.github.com/cpb-/spi-tools/tar.gz/$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=1f29548187c5a57ca5902d260b01ca9ce04d93e4406ff77f317e1d6423ed3610

PKG_MAINTAINER:=John Crispin <blogic@openwrt.org>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/spi-tools
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Command line SPI tools
endef

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
