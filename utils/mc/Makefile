#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mc
PKG_VERSION:=4.8.33
PKG_RELEASE:=1
PKG_MAINTAINER:=
PKG_LICENSE:=GPL-3.0-or-later
PKG_CPE_ID:=cpe:/a:midnight_commander:midnight_commander

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://ftp.osuosl.org/pub/midnightcommander/
PKG_HASH:=cae149d42f844e5185d8c81d7db3913a8fa214c65f852200a9d896b468af164c
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf gettext-version
PKG_BUILD_DEPENDS:=MC_VFS:libtirpc

PKG_CONFIG_DEPENDS := \
	CONFIG_PACKAGE_MC \
	CONFIG_MC_DIFFVIEWER \
	CONFIG_MC_EDITOR \
	CONFIG_MC_SUBSHELL \
	CONFIG_MC_LARGEFILE \
	CONFIG_MC_BACKGROUND \
	CONFIG_MC_CHARSET \
	CONFIG_MC_VFS

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/mc
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+glib2 +libncurses +libmount +libe2p +MC_VFS:libssh2 $(ICONV_DEPENDS)
  TITLE:=Midnight Commander - a powerful visual file manager
  URL:=https://midnight-commander.org
  MENU:=1
endef

define Package/mc/config
	source "$(SOURCE)/Config.in"
endef

define Package/mc/description
GNU Midnight Commander is a visual file manager.
It's a feature rich full-screen text mode application that allows you to copy,
move and delete files and whole directory trees, search for files and run commands in the subshell.
Internal viewer and editor are included as well.

endef

CONFIGURE_ARGS += \
	--enable-silent-rules \
	--disable-tests \
	--disable-doxygen-doc \
	--with-screen=ncurses \
	--without-x \

CONFIGURE_VARS += \
	ac_cv_search_addwstr=no \

ifeq ($(CONFIG_MC_DIFFVIEWER),)
CONFIGURE_ARGS += --without-diff-viewer
endif

ifeq ($(CONFIG_MC_EDITOR),)
CONFIGURE_ARGS += --without-internal-edit
endif

ifeq ($(CONFIG_MC_SUBSHELL),)
CONFIGURE_ARGS += --without-subshell
endif

ifeq ($(CONFIG_MC_LARGEFILE),)
CONFIGURE_ARGS += --disable-largefile
endif

ifeq ($(CONFIG_MC_BACKGROUND),)
CONFIGURE_ARGS += --disable-background
endif

ifeq ($(CONFIG_MC_CHARSET),)
CONFIGURE_ARGS += --disable-charset
endif

ifeq ($(CONFIG_MC_VFS),)
CONFIGURE_ARGS += --disable-vfs
else
TARGET_CPPFLAGS += -I$(STAGING_DIR)/usr/include/tirpc
endif

define Package/mc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mc $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/mc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/misc/mc.charsets $(1)/etc/mc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/misc/mc.ext.ini $(1)/etc/mc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/misc/mc.default.keymap $(1)/etc/mc/mc.keymap
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/misc/filehighlight.ini $(1)/etc/mc
	$(INSTALL_DIR) $(1)/usr/share/mc/help
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/doc/hlp/mc.hlp $(1)/usr/share/mc/help
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/misc/mc.menu $(1)/etc/mc
	$(INSTALL_DIR) $(1)/etc/mc/skins
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/misc/skins/default.ini $(1)/etc/mc/skins
	$(INSTALL_DIR) $(1)/usr/share/mc/syntax
	touch $(1)/usr/share/mc/syntax/Syntax
ifeq ($(CONFIG_MC_DIFFVIEWER),y)
	ln -sf mc $(1)/usr/bin/mcdiff
endif
ifeq ($(CONFIG_MC_EDITOR),y)
	ln -sf mc $(1)/usr/bin/mcedit
endif
ifeq ($(CONFIG_MC_VFS),y)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/vfs/sfs/sfs.ini $(1)/etc/mc
	$(INSTALL_DIR) $(1)/usr/lib/mc/extfs.d
endif
endef

define Package/mc/conffiles
/etc/mc/mc.menu
/etc/mc/skins/default.ini
endef

define Package/mc-skins
  TITLE:=Midnight Commander - a powerful visual file manager - skins
  URL:=https://midnight-commander.org
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+mc
endef

define Package/mc-skins/install
	$(INSTALL_DIR) $(1)/etc/mc/skins
	$(CP) $(PKG_BUILD_DIR)/misc/skins/*.ini $(1)/etc/mc/skins/
	$(RM) $(1)/etc/mc/skins/default.ini
endef

define Package/mc-skins/conffiles
/etc/mc/skins/
endef

$(eval $(call BuildPackage,mc))
$(eval $(call BuildPackage,mc-skins))
