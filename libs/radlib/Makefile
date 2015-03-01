#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=radlib
PKG_VERSION:=2.12.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/radlib
PKG_SHA1SUM:=1b3feace6d0361436c9e4ce9b06856195a5ac1b1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/radlib
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libpthread +libsqlite3
  TITLE:=Rapid Application Development Library
  URL:=http://www.radlib.teel.ws/
endef

define Package/radlib/description
	radlib is a rapid application development library for unix multi-process applications
endef

define Package/radlib-sqlite/description
  $(call Package/radlib/description)
  This package comes with sqlite support
endef

EXTRA_LDFLAGS=-lsqlite3
CONFIGURE_ARGS += \
	--prefix="$(TOOLCHAIN_DIR)/usr" \
	--enable-sqlite

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/h/rad*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/.libs/librad.so* $(1)/usr/lib/
endef

define Package/radlib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/.libs/librad.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/msgRouter/.libs/radmrouted $(1)/usr/bin/
endef

define Package/radlib-sqlite/install
	$(call Package/radlib/install,$(1))
endef

$(eval $(call BuildPackage,radlib))
