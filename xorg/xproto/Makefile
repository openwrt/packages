# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xproto
PKG_VERSION:=7.0.31
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.x.org/releases/individual/proto/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=c6f9747da0bd3a95f86b17fb8dd5e717c8f3ab7f0ece3ba1b247899ec1ef7747

PKG_BUILD_DEPENDS:=util-macros
HOST_BUILD_DEPENDS:=util-macros/host
HOST_BUILD_PARALLEL:=1
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/xproto
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=
  TITLE:=X11 core wire protocol and auxiliary headers
  URL:=http://xorg.freedesktop.org/
endef

CONFIGURE_ARGS += \
  --prefix=/usr

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/* \
	  $(1)/usr/include/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/pkgconfig \
	  $(1)/usr/lib/
endef

$(eval $(call BuildPackage,xproto))
$(eval $(call HostBuild))
