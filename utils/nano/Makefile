#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nano
PKG_VERSION:=9.3
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/nano
PKG_HASH:=a9affc52c9596ee0682bcdd4ceb3c0b235eb221d83d733dfd9b0dff45897cb0d

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
  TITLE:=GNU Nano text editor (default features)
  VARIANT:=plus
  DEFAULT_VARIANT:=1
  PROVIDES:=nano-plus
endef

define Package/nano-tiny
  $(call Package/nano/Default)
  TITLE:=GNU Nano text editor (minimal features)
  VARIANT:=tiny
endef

define Package/nano-full
  $(call Package/nano/Default)
  TITLE:=GNU Nano text editor (all features, Unicode)
  VARIANT:=full
endef

define Package/nano/Default/description
  Nano is a small and simple text editor for use on the terminal.
  (linewise scrolling, no automatic line breaking).
  Nano is an official GNU package.
endef

define Package/nano/description
  nano - Default features, larger than nano-tiny.
  (multibuffer, help, nanorc, syntax highlighting (uci, ucode, shell))
  Nano set as the default EDITOR in the shell profile.

  $(call Package/nano/Default/description)
endef

define Package/nano-tiny/description
  nano-tiny - Only minimal features enabled.
  $(call Package/nano/Default/description)
endef

define Package/nano-full/description
  nano-full - all features incl. nanorc, syntax highlighting,
  multibuffer, Unicode/UTF-8, some key bindings.
  (libmagic-based file type detection is still disabled)
  Nano set as the default EDITOR in the shell profile.

  $(call Package/nano/Default/description)
endef

ifeq ($(BUILD_VARIANT),full)
# full variant with almost all features included
  CONFIGURE_ARGS += \
	--disable-extra \
	--disable-libmagic \
	--enable-utf8
else ifeq ($(BUILD_VARIANT),tiny)
# tiny variant
  CONFIGURE_ARGS += \
	--enable-tiny \
	--enable-linenumbers \
	--disable-color \
	--disable-utf8
else
# default plus variant with some features included
  CONFIGURE_ARGS += \
	--enable-color \
	--enable-help \
	--enable-linenumbers \
	--enable-multibuffer \
	--enable-nanorc \
	--disable-browser \
	--disable-comment \
	--disable-extra \
	--disable-histories \
	--disable-justify \
	--disable-libmagic \
	--disable-mouse \
	--disable-operatingdir \
	--disable-speller \
	--disable-tabcomp \
	--disable-utf8 \
	--disable-wordcomp
endif

CONFIGURE_VARS += \
	ac_cv_header_regex_h=no \

define Package/nano/conffiles
/etc/nanorc
endef

define Package/nano-full/conffiles
/etc/nanorc
endef

define Package/nano-tiny/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/
endef

define Package/nano/install
	$(call Package/nano-tiny/install,$1)
	$(INSTALL_DIR) $(1)/etc/profile.d $(1)/usr/share/nano
	$(INSTALL_DATA) ./files/nanorc $(1)/etc/nanorc
	$(INSTALL_DATA) ./files/uci.nanorc $(1)/usr/share/nano
	$(INSTALL_DATA) ./files/ucode.nanorc $(1)/usr/share/nano
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/nano/javascript.nanorc $(1)/usr/share/nano
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/nano/patch.nanorc $(1)/usr/share/nano
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/nano/sh.nanorc $(1)/usr/share/nano
	$(INSTALL_DATA) ./files/nano-default-editor.sh $(1)/etc/profile.d
endef

define Package/nano-full/install
	$(call Package/nano/install,$1)
	$(CP) $(PKG_INSTALL_DIR)/usr/share/nano/*nanorc $(1)/usr/share/nano
	$(CP) $(PKG_INSTALL_DIR)/usr/share/nano/extra/*nanorc $(1)/usr/share/nano
	# for compatibility with old nanorc installations
	$(INSTALL_DIR) $(1)/usr/share/nano/extra
endef

$(eval $(call BuildPackage,nano-tiny))
$(eval $(call BuildPackage,nano))
$(eval $(call BuildPackage,nano-full))

