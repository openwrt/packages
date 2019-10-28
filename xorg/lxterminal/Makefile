# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=lxterminal
PKG_VERSION:=0.3.2
PKG_RELEASE:=1

PKG_SOURCE_URL:=@SF/lxde/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=3166b18493a8e55811b02aa0de825cbbea65e2b628e69006c1a65b98e1bb4484

#PKG_BUILD_DEPENDS:=vte
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/lxterminal
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libx11 +libxau +libxext +libxmu +libxaw +libxpm +gtk2 +vte
  TITLE:=Desktop-independent VTE-based terminal emulator
  URL:=http://xorg.freedesktop.org/
endef

CONFIGURE_ARGS += \
  --prefix=/usr

define Package/lxterminal/install
	$(INSTALL_DIR) \
	  $(1)/usr/bin

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/bin/
endef

$(eval $(call BuildPackage,lxterminal))
