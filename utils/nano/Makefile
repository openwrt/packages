#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nano
PKG_VERSION:=6.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/nano
PKG_HASH:=93ac8cb68b4ad10e0aaeb80a2dd15c5bb89eb665a4844f7ad01c67efcb169ea2

PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Jonathan Bennett <JBennett@incomsystems.biz>, Hannu Nyman <hannu.nyman@iki.fi>
PKG_CPE_ID:=cpe:/a:gnu:nano

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/nano
  SUBMENU:=Editors
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=GNU nano - enhanced clone of the Pico text editor
  URL:=https://www.nano-editor.org/
  DEPENDS:=+libncurses
endef

define Package/nano/description
  Nano is a small and simple text editor for use on the terminal.

  Nano started as an enhanced clone of the Pico text editor.
  Nowadays Nano wants to be a generally useful editor with sensible
  defaults (linewise scrolling, no automatic line breaking).

  Nano is an official GNU package.
endef

CONFIGURE_ARGS += \
	--enable-tiny \
	--disable-utf8 \
	--disable-color \
	--enable-linenumbers

CONFIGURE_VARS += \
	ac_cv_header_regex_h=no \

define Package/nano/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/
endef

$(eval $(call BuildPackage,nano))

