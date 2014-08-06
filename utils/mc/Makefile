#
# Copyright (C) 2006-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mc
PKG_VERSION:=4.8.12
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://www.midnight-commander.org/downloads/
PKG_MD5SUM:=7ecccc03df060cd0ca1414a5a14e6649
PKG_MAINTAINER:=Eugene San (eugenesan) <eugenesan@gmail.com>

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/mc
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+glib2 +libslang2 +bash $(LIBRPC_DEPENDS) $(ICONV_DEPENDS)
  TITLE:=midnight commander - a powerful file manager
  URL:=http://www.midnight-commander.org/
  SUBMENU:=filemanager
  MENU:=1
endef

define Package/mc/config
	source "$(SOURCE)/Config.in"
endef

define Package/mc/description
 GNU Midnight Commander is a visual file manager, licensed under GNU General
 Public License and therefore qualifies as Free Software. It's a feature rich
 full-screen text mode application that allows you to copy, move and delete
 files and whole directory trees, search for files and run commands in the
 subshell.
endef

CONFIGURE_ARGS += \
	--with-screen=slang \
	--enable-utf8 \
	--disable-doxygen-doc \
	--disable-vfs-sftp \
	--without-gpm-mouse \
	--without-x \
	ac_cv_search_addwstr=no

ifeq ($(CONFIG_MC_DIFF_VIEWER),n)
CONFIGURE_ARGS += \
	--without-diff-viewer
endif

ifeq ($(CONFIG_MC_EDITOR),n)
CONFIGURE_ARGS += \
	--without-edit
endif

ifeq ($(CONFIG_MC_SUBSHELL),n)
CONFIGURE_ARGS += \
	--without-subshell
endif

ifeq ($(CONFIG_MC_VFS),n)
CONFIGURE_ARGS += \
	--without-vfs
endif

define Package/mc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mc $(1)/usr/bin
ifeq ($(CONFIG_MC_VIEWER),y)
	ln -sf mc $(1)/usr/bin/mcview
endif
ifeq ($(CONFIG_MC_DIFF_VIEWER),y)
	ln -sf mc $(1)/usr/bin/mcdiff
endif
ifeq ($(CONFIG_MC_EDITOR),y)
	ln -sf mc $(1)/usr/bin/mcedit
endif
	$(INSTALL_DIR) $(1)/etc/mc
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/mc/* $(1)/etc/mc
	$(INSTALL_DIR) $(1)/usr/lib/mc/{ext.d,extfs.d,fish}
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/mc/{cons*,mc*} $(1)/usr/lib/mc
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/mc/ext.d/*.sh $(1)/usr/lib/mc/ext.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/mc/extfs.d/* $(1)/usr/lib/mc/extfs.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/mc/fish/* $(1)/usr/lib/mc/fish
	$(INSTALL_DIR) $(1)/usr/share/mc/{examples/macros.d,help,hints,skins,syntax}
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/mc/mc* $(1)/usr/share/mc
ifeq ($(CONFIG_MC_DOC),y)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/mc/examples/macros.d/* $(1)/usr/share/mc/examples/macros.d
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/mc/help/* $(1)/usr/share/mc/help
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/mc/hints/* $(1)/usr/share/mc/hints
endif
ifeq ($(CONFIG_MC_MAN),y)
	$(INSTALL_DIR) $(1)/usr/man/man1
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/man/man1/* $(1)/usr/man/man1
endif
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/mc/skins/* $(1)/usr/share/mc/skins
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/mc/syntax/* $(1)/usr/share/mc/syntax
endef

define Package/mc/conffiles
/etc/mc/mc.menu
/etc/mc/skins/default.ini
endef

$(eval $(call BuildPackage,mc))
