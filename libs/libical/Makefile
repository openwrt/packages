#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libical
PKG_VERSION:=3.0.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=5c8a21c2b732ece4a33e5c862970b4f35a8548bbcda50de5695f6fc211ac4d97
PKG_SOURCE_URL:=https://github.com/libical/libical/releases/download/v$(PKG_VERSION)/

PKG_MAINTAINER:=Jose Zapater <jzapater@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later MPL-2.0
PKG_LICENSE_FILES:=COPYING

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libical
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=An implementation of iCalendar protocols and data formats
  URL:=http://libical.github.io/libical/
  DEPENDS:=+libpthread
endef

define Package/libical/description
 Libical is an Open Source implementation of the iCalendar protocols and protocol
 data units. The iCalendar specification describes how calendar clients can
 communicate with calendar servers so users can store their calendar data and
 arrange meetings with other users.
 Libical implements RFC2445, RFC2446 and some of RFC2447.
endef

CMAKE_OPTIONS += -DWITH_CXX_BINDINGS=false -DICAL_BUILD_DOCS=false -DICAL_GLIB=false

define Package/libical/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libical{,ss,vcal}.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libical))
