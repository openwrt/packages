#
# Copyright (C) 2021 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mongoose
PKG_RELEASE:=1

PKG-BRANCH=main
PKG_SOURCE_URL=https://github.com/TheRootED24/libmongoose.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2024-08-17

PKG_SOURCE_VERSION:=7ed296cba65a1a02f1f686ed1c8858d0c7eea114
PKG_MIRROR_HASH:=464b457e970412bd69da2cc94be05616a468d94c1a923ce755ab00961d915544

PKG_MAINTAINER:=Scott Mercer <TheRootED24@gmail.com>

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/mongoose
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=OpenWrt Mongoose C Networking shared Library
  DEPENDS:=+libopenssl
endef

TARGET_CFLAGS += -std=gnu99 -I$(STAGING_DIR)/usr/include/mongoose/

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/mongoose
	$(CP) \
		$(PKG_BUILD_DIR)/src/*.h \
		$(1)/usr/include/mongoose/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_BUILD_DIR)/src/libmongoose.so* \
		$(1)/usr/lib/
	
endef

define Package/mongoose/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipkg-install/usr/lib/libmongoose.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,mongoose))
