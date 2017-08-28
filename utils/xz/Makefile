#
# Copyright (C) 2013-2015 OpenWrt.org
# Copyright (C) 2017 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xz
PKG_VERSION:=5.2.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/lzmautils \
		http://tukaani.org/xz
PKG_HASH:=fd9ca16de1052aac899ad3495ad20dfa906c27b4a5070102a2ec35ca3a4740c1

PKG_LICENSE:=Public-Domain LGPL-2.1+ GPL-2.0+ GPL-3.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xz/Default
  SUBMENU:=Compression
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=http://tukaani.org/xz
endef

define Package/xz-utils
$(call Package/xz/Default)
  TITLE:=XZ Utils (meta)
  MENU:=1
endef

define Package/liblzma
$(call Package/xz/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libpthread
  TITLE:=liblzma library from XZ Utils
endef

# $(1): package name & command in /usr/bin/
# $(2): package dependencies
# $(3): symbolic links to $(1) in /usr/bin/
define BuildSubPackage

  define Package/$(1)
  $(call Package/xz/Default)
    DEPENDS:=xz-utils $(2)
    TITLE:=$(1) utility from XZ Utils
  endef

  define Package/$(1)/description
   Contains: $(1) $(3)
  endef

  define Package/$(1)/install
	$(INSTALL_DIR) $$(1)/usr/bin
	$(CP) $(foreach f,$(1) $(3),$(PKG_INSTALL_DIR)/usr/bin/$(f)) $$(1)/usr/bin/
  endef

  $$(eval $$(call BuildPackage,$(1)))
endef


CONFIGURE_ARGS += \
	--enable-small \
	--enable-assume-ram=4 \
	--disable-assembler \
	--disable-werror \

# API uses "restrict" keyword introduced in C99 standard
TARGET_CFLAGS += \
	-std=c99 \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/lzma{,.h} \
		$(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/liblzma.{a,so*} \
		$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/liblzma.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/xz-utils/install
	true
endef

define Package/liblzma/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblzma.so.* $(1)/usr/lib/
endef


$(eval $(call BuildPackage,xz-utils))
$(eval $(call BuildPackage,liblzma))
$(eval $(call BuildSubPackage,lzmadec, +liblzma,))
$(eval $(call BuildSubPackage,lzmainfo, +liblzma,))
$(eval $(call BuildSubPackage,xz, +liblzma, lzcat lzma unlzma unxz xzcat))
$(eval $(call BuildSubPackage,xzdec, +liblzma,))
$(eval $(call BuildSubPackage,xzdiff, +bash +xz, lzcmp lzdiff xzcmp))
$(eval $(call BuildSubPackage,xzgrep, +bash +xz, lzegrep lzfgrep lzgrep xzegrep xzfgrep))
$(eval $(call BuildSubPackage,xzless, +bash +xz, lzless))
$(eval $(call BuildSubPackage,xzmore, +bash +xz, lzmore))
