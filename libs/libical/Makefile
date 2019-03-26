#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libical
PKG_VERSION:=3.0.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=72b216e10233c3f60cb06062facf41f3b0f70615e5a60b47f9853341a0d5d145
PKG_SOURCE_URL:=https://github.com/libical/libical/releases/download/v$(PKG_VERSION)/

PKG_LICENSE:=LGPL-2.1 MPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Jose Zapater <jzapater@gmail.com>

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

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libical
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libical/* $(1)/usr/include/libical/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libical{,ss,vcal}.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libical.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libical/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libical{,ss,vcal}.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libical))
