#
# Copyright (C) 2006-2011 Openwrt.org
# Copyright (C) 2011 SMBPhone Inc.
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=slang
PKG_VERSION:=2.2.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=ftp://space.mit.edu/pub/davis/slang/v2.2 \
	ftp://space.mit.edu/pub/davis/slang/v2.2/OLD
PKG_MD5SUM:=7fcfd447e378f07dd0c0bae671fe6487

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libslang2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=S-Lang v2.2
  URL:=http://www.jedsoft.org/slang
  DEPENDS:= +terminfo
endef

define Package/libslang2/description
  Multi-platform programmer's library providing facilities for interactive
  applications.  Includes such things as display/screen management,
  keyboard input, keymaps, etc.  Includes the embeddable S-Lang interpreter.
endef

define Package/slsh
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=S-Lang Shell
  URL:=http://www.jedsoft.org/slang/slsh.html
  DEPENDS:= +libslang2
endef

define Package/libslang2/description
  This is a shell which is mostly just a wrapper around the S-Lang Interpreter,
  which is part of the S-Lang Library.
endef

TARGET_CFLAGS += $(FPIC)
TARGET_LDFLAGS += -L../src/${ARCH}elfobjs

CONFIGURE_ARGS += \
	--enable-largefile \
	--disable-warnings \
	--with-terminfo=default \
	--with-readline=slang \
	--without-x \
	--without-pcre \
	--without-onig \
	--without-png \
	--without-z \
	ac_cv_path_nc5config=$(PWD)/files/ncurses5-config

define Build/Compile
	$(call Build/Compile/Default)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		static install install-static
endef

define Package/libslang2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libslang.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/slang/ $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{include,lib,lib/pkgconfig}
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libslang.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/slsh/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/slsh $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share
	$(CP) $(PKG_INSTALL_DIR)/usr/share/slsh/ $(1)/usr/share/
endef

$(eval $(call BuildPackage,libslang2))
$(eval $(call BuildPackage,slsh))
