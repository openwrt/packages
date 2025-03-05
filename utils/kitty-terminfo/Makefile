#
# Copyright (C) 2022 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=kitty-terminfo
PKG_VERSION:=0.35.2
PKG_RELEASE:=1

PKG_LICENSE:=GPL-3.0-only

PKG_SOURCE:=kitty-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/kovidgoyal/kitty/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=35ecf63999a056ff691abab94a6f82328f4e432c8e229a69d02c25466be4398f

PKG_BUILD_DIR:=$(BUILD_DIR)/kitty-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/kitty-terminfo
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Terminal
  TITLE:=Terminfo for kitty, an OpenGL-based terminal emulator
  DEPENDS:=+libncurses
  URL:=https://sw.kovidgoyal.net/kitty/
  PKGARCH:=all
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/kitty-terminfo/install
	$(INSTALL_DIR) $(1)/usr/share/terminfo
	tic -x -o $(1)/usr/share/terminfo $(PKG_BUILD_DIR)/terminfo/kitty.terminfo
endef

$(eval $(call BuildPackage,kitty-terminfo))
