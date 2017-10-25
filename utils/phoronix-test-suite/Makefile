#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=phoronix-test-suite
PKG_VERSION:=7.4.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/$(PKG_NAME)/$(PKG_NAME).git
PKG_SOURCE_VERSION:=8b797189b115d9e46cedaeba1ada287c0f9a66b4
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=f8c4ba0e1f48833c1770056ec580e38b6bec0fc51cad64fe32533b1b81c75ff1

PKG_MAINTAINER:=Lucas Ramage <ramage.lucas94@gmail.com>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/phoronix-test-suite
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Phoronix Test Suite
  DEPENDS:= +php7-cli
  URL:=https://www.phoronix-test-suite.com
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
