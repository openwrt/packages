#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nano
PKG_VERSION:=6.2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/nano
PKG_HASH:=2bca1804bead6aaf4ad791f756e4749bb55ed860eec105a97fba864bc6a77cb3

PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Hannu Nyman <hannu.nyman@iki.fi>
PKG_CPE_ID:=cpe:/a:gnu:nano

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/nano/Default
  SUBMENU:=Editors
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://www.nano-editor.org/
  DEPENDS:=+libncurses
endef

define Package/nano
  $(call Package/nano/Default)
  TITLE:=GNU nano text editor (minimal features)
  VARIANT:=tiny
  DEFAULT_VARIANT:=1
endef

define Package/nano-plus
  $(call Package/nano/Default)
  TITLE:=GNU nano text editor (more features, Unicode)
  VARIANT:=plus
endef

define Package/nano-full
  $(call Package/nano/Default)
  TITLE:=GNU nano text editor (all features, Unicode)
  VARIANT:=full
endef

define Package/nano/description
  Nano is a small and simple text editor for use on the terminal.

  Nano started as an enhanced clone of the Pico text editor.
  Nowadays Nano wants to be a generally useful editor with sensible
  defaults (linewise scrolling, no automatic line breaking).

  Nano is an official GNU package.
endef

define Package/nano-plus/description
  nano-plus - Additional features enabled, larger size than default nano.
  (multibuffer, Unicode/UTF-8, help, justify, nanorc, some key bindings)

  $(call Package/nano/description)
endef

define Package/nano-full/description
  nano-full - all features, including syntax highlighting (also uci),
  multibuffer, Unicode/UTF-8, nanorc, some key bindings.
  (libmagic-based file type detection is disabled)

  Example /etc/nanorc is included. nanorc documentation at
  https://www.nano-editor.org/dist/latest/nanorc.5.html

  $(call Package/nano/description)
endef

ifeq ($(BUILD_VARIANT),full)
# full variant with almost all features included
  CONFIGURE_ARGS += \
	--disable-extra \
	--disable-libmagic \
	--enable-utf8
else ifeq ($(BUILD_VARIANT),plus)
# plus variant with some features included
  CONFIGURE_ARGS += \
	--enable-help \
	--enable-justify \
	--enable-linenumbers \
	--enable-multibuffer \
	--enable-nanorc \
	--enable-utf8 \
	--disable-browser \
	--disable-color \
	--disable-comment \
	--disable-extra \
	--disable-histories \
	--disable-libmagic \
	--disable-mouse \
	--disable-operatingdir \
	--disable-speller \
	--disable-tabcomp \
	--disable-wordcomp
else
# default tiny variant
  CONFIGURE_ARGS += \
	--enable-tiny \
	--enable-linenumbers \
	--disable-color \
	--disable-utf8
endif

CONFIGURE_VARS += \
	ac_cv_header_regex_h=no \

define Package/nano-plus/conffiles
/etc/nanorc
endef

define Package/nano-full/conffiles
/etc/nanorc
endef

define Package/nano/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/
endef

define Package/nano-plus/install
	$(call Package/nano/install,$1)
endef

define Package/nano-full/install
	$(call Package/nano/install,$1)
	$(INSTALL_DIR) $(1)/etc $(1)/usr/share/nano
	$(INSTALL_CONF) ./files/nanorc $(1)/etc/nanorc
	$(INSTALL_DATA) ./files/uci.nanorc $(1)/usr/share/nano
	$(CP) $(PKG_INSTALL_DIR)/usr/share/nano/* $(1)/usr/share/nano
endef

$(eval $(call BuildPackage,nano))
$(eval $(call BuildPackage,nano-plus))
$(eval $(call BuildPackage,nano-full))

