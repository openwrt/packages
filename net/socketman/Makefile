# Copyright (C) 2016 Cucumber WiFi
#
# This is free software, licensed under the GNU General Public License v2.

export CT_ARCH="-D__OPENWRT__"

include $(TOPDIR)/rules.mk

PKG_NAME:=SocketMan
PKG_SOURCE_PROTO:=git
PKG_MAINTAINER:=Cucumber Bot <build_bot@cucumberwifi.io>
PKG_LICENSE:=GPL-2
PKG_SOURCE_VERSION:=02dabd47aa5297db19c9e1d1ef716d2e2a4b772b
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE_URL:=https://github.com/cucumber-tony/SocketMan.git
PKG_SOURCE:=$(PKG_NAME).tar.gz
PKG_VERSION:=v1

include $(INCLUDE_DIR)/package.mk

define Package/socketman
SECTION:=net
CATEGORY:=Network
DEPENDS:=+zlib +libjson-c +curl +libcurl +libopenssl +libpthread +libmosquitto +@LIBCURL_OPENSSL +libc +libnl
TITLE:=SocketMan communication package for Cucumber Tony
URL:=http://www.cucumberwifi.io
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)/build
	mkdir -p $(PKG_BUILD_DIR)/obj
	tar -C $(DL_DIR) -xzvf $(DL_DIR)/$(PKG_NAME).tar.gz
	$(CP) $(DL_DIR)/$(PKG_NAME)/src/* $(PKG_BUILD_DIR)/
endef

define Package/socketman/description
 This package contains the communication package of CT
endef

define Package/socketman/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/socketman $(1)/usr/bin/socketman
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/socketman.init $(1)/etc/init.d/socketman
endef

$(eval $(call BuildPackage,socketman))

.PHONY: clean
clean:
	rm -rf $(DL_DIR)/$(PKG_NAME)*
