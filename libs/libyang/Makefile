#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libyang
PKG_VERSION:=2.0.112
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/CESNET/libyang/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=184dd67c66c1ad968a2ee4d0950fb6b103834917b04b17af9c7bca80967636ee

PKG_MAINTAINER:=Jakov Smolic <jakov.smolic@sartura.hr>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:cesnet:libyang

CMAKE_INSTALL:=1
CMAKE_BINARY_SUBDIR:=build

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libyang
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=YANG data modeling language library
  URL:=https://github.com/CESNET/libyang
  DEPENDS:=+libpcre2 +libpthread
endef

define Package/yanglint
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=YANG data modeling language utility
  URL:=https://github.com/CESNET/libyang
  DEPENDS:=+libyang
endef

define Package/libyang/description
 libyang is YANG data modelling language parser and toolkit written (and providing API) in C.
 The library is used e.g. in libnetconf2, Netopeer2 or sysrepo projects.
endef

define Package/libyang/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libyang.so* $(1)/usr/lib/
endef

define Package/yanglint/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/yanglint $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libyang))
$(eval $(call BuildPackage,yanglint))
