#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libyang
PKG_VERSION:=0.13.46
PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_LICENSE:=GPL-2.0+
PKG_MAINTAINER:=Mislav Novakovic <mislav.novakovic@sartura.hr>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=d1556e0ae3872d676dfd63bd6073fe7e72d0130f
PKG_MIRROR_HASH:=4a23a3854ceca147e113ab65ecdce3371e30b59436680e7d981b0bab6dbe751d
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/CESNET/libyang.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)

PKG_BUILD_ROOT:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_DIR:=$(PKG_BUILD_ROOT)

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
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libyang/* $(1)/usr/lib/libyang/
endef

define Package/yanglint/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/yanglint $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libyang))
$(eval $(call BuildPackage,yanglint))
