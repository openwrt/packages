#
# Copyright (C) 2026 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=faux
PKG_VERSION:=2.2.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pkun/faux.git
PKG_SOURCE_DATE:=2025-10-20
PKG_SOURCE_VERSION:=532d1cb79b65de0227020a39ecd48deb78ac2867
PKG_MIRROR_HASH:=777eb62d489970e0e6a796f9d250712d89ab4ece9691128e940e646c797d72da

PKG_MAINTAINER:=Dharmik Parmar <dharmikparmar2004@yahoo.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENCE

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libfaux
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Auxiliary utility library used by klish3
  URL:=https://github.com/pkun/faux
  DEPENDS:=+libpthread
endef

define Package/libfaux/description
 The faux library contains assorted helper APIs for memory, strings,
 event loops, async I/O and utility wrappers.
endef

define Package/faux-utils
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Utilities from faux library
  URL:=https://github.com/pkun/faux
  DEPENDS:=+libfaux
endef

define Package/faux-utils/description
 Utility binaries shipped by the faux project.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/faux $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfaux.so* $(1)/usr/lib/
endef

define Package/libfaux/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfaux.so* $(1)/usr/lib/
endef

define Package/faux-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/faux-file2c $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/faux-getch $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libfaux))
$(eval $(call BuildPackage,faux-utils))
