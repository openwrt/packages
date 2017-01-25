#
# Copyright (C) 2014-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=hamlib
PKG_VERSION:=3.0.1
PKG_RELEASE:=1
PKG_MD5SUM:=451acb9f727ed706ae2f59ee3f0e03c7

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/hamlib
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=Vasilis Tsiligiannis <acinonyx@openwrt.gr>

include $(INCLUDE_DIR)/package.mk

define Package/hamlib/Default
  TITLE:=Ham Radio Control
  URL:=http://hamlib.sourceforge.net
endef

define Package/hamlib/Default/description
  Ham Radio Control Libraries is a development effort to provide a consistent
  interface for programmers wanting to incorporate radio control in their
  programs.
endef

define Package/hamlib
  $(call Package/hamlib/Default)
  TITLE+= utilities
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libhamlib
endef

define Package/hamlib/description
  $(call Package/hamlib/Default/description)

  This package contains the utilities and daemons.
endef

define Package/libhamlib/Default
  $(call Package/hamlib/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= shared library
endef

define Package/libhamlib
  $(call Package/libhamlib/Default)
  DEPENDS:=+libusb-1.0
  MENU:=1
endef

define Package/libhamlib/description
  $(call Package/hamlib/Default/description)

  This package contains the hamlib shared library.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/hamlib/*.h $(1)/usr/include/hamlib
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhamlib.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/hamlib.pc $(1)/usr/lib/pkgconfig/
endef

CONFIGURE_ARGS+= \
	--disable-html-matrix \
	--disable-winradio \
	--without-readline \
	--without-cxx-binding \
	--with-pic \

CONFIGURE_VARS+= \
	LIBUSB_LIBS="-lusb-1.0" \

define Package/hamlib/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/{rig,rot}* $(1)/usr/bin/
endef

define Package/libhamlib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhamlib.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,hamlib))
$(eval $(call BuildPackage,libhamlib))
