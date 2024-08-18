#
# Copyright (C) 2021 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=jsonmg
PKG_RELEASE:=1

PKG_SOURCE_URL=https://github.com/TheRootED24/jsonmg.git
PKG-BRANCH=main
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2024-08-15
			
PKG_SOURCE_VERSION:=6a1d6b78bc736ac680c9b0bb4b0a873ef92ba70d

PKG_MIRROR_HASH:=bc63690b7e63f27ca73ea9e3802a9b57226bf632f5000b37ce8c7b0f26008698

PKG_MAINTAINER:=Scott Mercer <TheRootED24@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_FLAGS:=lto

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/jsonmg
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:= A basic JSON parsing and serialization library. 
  DEPENDS:=+mgjson +liblua
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/mgjson/

define Package/jsonmg/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/jsonmg
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipkg-install/usr/lib/lua/jsonmg/jsonmg.so $(1)/usr/lib/lua/jsonmg
endef

$(eval $(call BuildPackage,jsonmg))