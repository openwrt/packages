#
# Copyright (C) 2012-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ecdsautils
PKG_VERSION:=0.4.1
PKG_RELEASE:=1
PKG_REV:=39b6d0a77414fd41614953a0e185c4eefa2f88ad
PKG_MAINTAINER:=Matthias Schiffer <mschiffer@universe-factory.net>
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=b6022455af1e126c3893b19b65d5efbda6c1e5105745891481e0b9bf8e1aeb53
PKG_SOURCE_URL:=git://github.com/tcatm/$(PKG_NAME).git
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_PROTO:=git

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libecdsautil
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libuecc
  TITLE:=ECDSA library
  URL:=https://github.com/freifunk-gluon/ecdsautils
endef

define Package/ecdsautils
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libecdsautil +libuecc
  TITLE:=ECDSA Utilities
  URL:=https://github.com/freifunk-gluon/ecdsautils
endef

CMAKE_OPTIONS += \
  -DCMAKE_BUILD_TYPE:String="MINSIZEREL" \


define Package/libecdsautil/description
 Library to sign and verify checksums using ECDSA.
endef

define Package/ecdsautils/description
 Utilities to sign and verify checksums using ECDSA.
endef

define Package/libecdsautil/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libecdsautil.so* $(1)/usr/lib/
endef

define Package/ecdsautils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ecdsautil $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ecdsakeygen $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ecdsasign $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ecdsaverify $(1)/usr/bin/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/
	$(CP) $(PKG_INSTALL_DIR)/usr/include $(1)/usr/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib $(1)/usr/
endef

$(eval $(call BuildPackage,libecdsautil))
$(eval $(call BuildPackage,ecdsautils))
