#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=phoronix-test-suite
PKG_VERSION:=7.6.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/$(PKG_NAME)/$(PKG_NAME).git
PKG_SOURCE_VERSION:=35b5d28c4b36e4605337c18f1d296c62f7c1b943
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=c409be49eb0c2f8781924ef16367fce7cb1bd3b9830c6cf830e56b346b7a7259

PKG_MAINTAINER:=Lucas Ramage <ramage.lucas94@gmail.com>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/phoronix-test-suite/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Phoronix Test Suite
  DEPENDS:= +php7-cli +php7-mod-dom +php7-mod-json +php7-mod-simplexml
  URL:=https://www.phoronix-test-suite.com
endef

define Package/phoronix-test-suite
  $(call Package/phoronix-test-suite/Default)
  MENU:=1
endef

define Package/phoronix-test-suite/description
  The Phoronix Test Suite is a comprehensive testing and benchmarking platform 
  available that provides an extensible framework for which new tests can be easily added.
  The software is designed to effectively carry out both qualitative and quantitative 
  benchmarks in a clean, reproducible, and easy-to-use manner.
endef

define Build/Compile
endef

define Package/phoronix-test-suite/install
	$(INSTALL_DIR) $(1)/usr/share/$(PKG_NAME)
	$(CP) $(PKG_BUILD_DIR)/pts-core/ $(1)/usr/share/$(PKG_NAME)/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/bin/
endef

$(eval $(call BuildPackage,phoronix-test-suite))
