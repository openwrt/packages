#
# Copyright (C) 2012-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libplist
PKG_SOURCE_VERSION:=2.1.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/libimobiledevice/libplist
PKG_MIRROR_HASH:=452ef5d6e87461a8b7a47a2274878cf200ccf480b4e81924f22ec1c445e353d0

PKG_MAINTAINER:=

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/libplist/Default
  TITLE:=Apple property list
  URL:=https://www.libimobiledevice.org/
endef

define Package/libplist/Default/description
  A library to handle Apple Property List format whereas it's binary or XML
endef

define Package/libplist
  $(call Package/libplist/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libxml2
  TITLE+= library
  PKG_LICENSE:=LGPL-2.1-or-later
  PKG_LICENSE_FILES:=COPYING.LESSER
endef

define Package/libplist/description
  $(call Package/libplist/Default/description)
endef

define Package/libplistcxx
  $(call Package/libplist/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libplist $(CXX_DEPENDS)
  TITLE+= C++ library
  PKG_LICENSE:=LGPL-2.1-or-later
  PKG_LICENSE_FILES:=COPYING.LESSER
endef

define Package/libplistcxx/description
  $(call Package/libplist/Default/description)
  This package contains the libplist C++ shared library.
endef

define Package/libplist-utils
  $(call Package/libplist/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libplist
  TITLE+= converter
  LICENSE:=GPL-2.0-or-later
  LICENSE_FILES:=COPYING
endef

define Package/libplist-utils/description
  $(call Package/libplist/Default/description)
  This package contains the libplist utilities.
endef

CONFIGURE_ARGS += \
	--without-cython

TARGET_CFLAGS += -flto
TARGET_CXXFLAGS += -std=c++11 -fno-rtti
TARGET_LDFLAGS += -Wl,--gc-sections

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/plist $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libplist*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libplist*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libplist/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libplist.so.* $(1)/usr/lib/
endef

define Package/libplistcxx/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libplist++.so.* $(1)/usr/lib/
endef

define Package/libplist-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/plistutil $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libplist))
$(eval $(call BuildPackage,libplistcxx))
$(eval $(call BuildPackage,libplist-utils))
