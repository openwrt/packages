#
# Copyright (C) 2021 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mgjson
PKG_RELEASE:=1

PKG-BRANCH=main
PKG_SOURCE_URL=https://github.com/TheRootED24/mgjson.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2024-08-17

PKG_SOURCE_VERSION:=9793e7ba97f1197909dda8fa3002673e4dd7266b
PKG_MIRROR_HASH:=85c5b3c3704e0b834f4d315b345baadd79a5e972bf688f46269d2887d4ae6acd

PKG_MAINTAINER:=Scott Mercer <TheRootED24@gmail.com>

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/mgjson
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A Stripped down OpenWrt version of Mongoose C Networking. mgjson provides only the mg_json, mg_str, and mg_iobuf, functionilty of the Mongoose Library.
endef

TARGET_CFLAGS += -std=gnu99 -I$(STAGING_DIR)/usr/include/mgjson/

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/mgjson
	$(CP) \
		$(PKG_BUILD_DIR)/src/*.h \
		$(1)/usr/include/mgjson/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_BUILD_DIR)/src/libmgjson.so \
		$(1)/usr/lib/
	
endef

define Package/mgjson/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipkg-install/usr/lib/libmgjson.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,mgjson))
