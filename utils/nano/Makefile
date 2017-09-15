#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nano
PKG_VERSION:=2.8.7
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/nano
PKG_HASH:=fbe31746958698d73c6726ee48ad8b0612697157961a2e9aaa83b4aa53d1165a

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/nano
  SUBMENU:=Editors
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=An enhanced clone of the Pico text editor
  URL:=http://www.nano-editor.org/
  MAINTAINER:=Jonathan Bennett <JBennett@incomsystems.biz>
  DEPENDS:=+libncurses
endef

define Package/nano/description
  Nano (Nano's ANOther editor, or Not ANOther editor) is an enhanced clone
  of the Pico text editor.
endef

CONFIGURE_ARGS += \
	--enable-tiny \
	--disable-utf8 \
	--without-slang \
	--disable-color \

CONFIGURE_VARS += \
	ac_cv_header_regex_h=no \

define Package/nano/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/
endef

$(eval $(call BuildPackage,nano))

