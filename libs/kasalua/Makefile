#
# Copyright (C) 2021 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=kasalua
PKG_RELEASE:=1

PKG_SOURCE_URL=https://github.com/TheRootED24/kasalua.git
PKG-BRANCH=main
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2024-07-28

PKG_SOURCE_VERSION:=8b8c3ef4ba7904a59ad93ad176dbad2244a1c94b
PKG_MIRROR_HASH:=6bb74ecad467044c12cb364c067aebc2f857f40b1d94259ce89dd4187e85d911

PKG_MAINTAINER:=Scott Mercrer <TheRootED24@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENCE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/kasalua
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=OpenWrt kasalua provides high level lua binding to the Kasa C interface library with minimal overhead
  DEPENDS:=+liblua
endef

TARGET_CFLAGS += -std=gnu99 -I$(STAGING_DIR)/usr/include/kasalua/

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/kasalua
	$(CP) \
		$(PKG_BUILD_DIR)/src/*.h \
		$(1)/usr/include/kasalua/

	$(INSTALL_DIR) $(1)/usr/lib/lua/kasalua
	$(CP) \
		$(PKG_BUILD_DIR)/src/kasa.so* \
		$(1)/usr/lib/lua/kasalua/
	
endef

define Package/kasalua/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/kasalua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipkg-install/usr/lib/lua/kasa/kasa.so* $(1)/usr/lib/lua/kasalua/
endef

$(eval $(call BuildPackage,kasalua))