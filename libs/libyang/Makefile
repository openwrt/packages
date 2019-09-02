#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libyang
PKG_VERSION:=0.16-r3
PKG_RELEASE:=4

PKG_LICENSE:=GPL-2.0-or-later
PKG_MAINTAINER:=Mislav Novakovic <mislav.novakovic@sartura.hr>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/CESNET/libyang/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=4745460dedc4ba17d8bcfc39ad9ba0d1b91bbe82b55b9417a090390909ba8ca5

CMAKE_INSTALL:=1

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libyang
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=YANG data modeling language library
  URL:=$(PKG_SOURCE_URL)
  DEPENDS:=+libpcre +libpthread
endef

define Package/yanglint
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=YANG data modeling language utility
  URL:=$(PKG_SOURCE_URL)
  DEPENDS:=+libyang
endef

define Package/libyang/description
 libyang is YANG data modelling language parser and toolkit written (and providing API) in C.
 The library is used e.g. in libnetconf2, Netopeer2 or sysrepo projects.
endef

TARGET_LDFLAGS += -lm

CMAKE_OPTIONS += \
	-DCMAKE_INSTALL_PREFIX:PATH=/usr \
	-DENABLE_LYD_PRIV:BOOL=ON \
	-DCMAKE_BUILD_TYPE:STRING=Release

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libyang.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/include/libyang
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/include/libyang/* $(1)/usr/include/libyang/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libyang.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libyang/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libyang.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/libyang
	$(INSTALL_DIR) $(1)/usr/lib/libyang/extensions
	$(INSTALL_DIR) $(1)/usr/lib/libyang/user_types
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libyang/extensions/* $(1)/usr/lib/libyang/extensions
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libyang/user_types/* $(1)/usr/lib/libyang/user_types
endef

define Package/yanglint/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/yanglint $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libyang))
$(eval $(call BuildPackage,yanglint))
