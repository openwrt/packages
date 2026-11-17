#
# This software is licensed under the CC0-1.0 license.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=sockread
PKG_VERSION:=1.1
PKG_RELEASE:=1
PKG_LICENSE:=CC0-1.0

include $(INCLUDE_DIR)/package.mk

define Package/sockread
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=Unix domain sockets utility
	MAINTAINER:=Moritz Warning <moritzwarning@web.de>
endef

define Package/sockread/description
	Command line utility to read and write to Unix domain sockets.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/sockread/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sockread $(1)/usr/bin/
endef

$(eval $(call BuildPackage,sockread))
