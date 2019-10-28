# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xsetroot
PKG_VERSION:=1.1.2
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://xorg.freedesktop.org/releases/individual/app/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=10c442ba23591fb5470cea477a0aa5f679371f4f879c8387a1d9d05637ae417c

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xsetroot
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libx11 +libxcursor +xbitmaps +libxmu
  TITLE:=is the root window parameter setting utility for X
  URL:=http://xorg.freedesktop.org/
endef

define Package/xsetroot/install
	$(INSTALL_DIR) \
	  $(1)/usr/bin

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/bin/
endef

$(eval $(call BuildPackage,xsetroot))

