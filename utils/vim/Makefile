#
# Copyright (C) 2015-2026 OpenWrt.org
#
# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=vim
PKG_VERSION:=9.2.0
PKG_XXD_VERSION:=2025.11.26
PKG_RELEASE:=1
VIMVER:=92

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/vim/vim.git
PKG_SOURCE_VERSION=v$(PKG_VERSION)
PKG_MIRROR_HASH:=92c6fe490fba758bc0a626863713d65c078d2abdbd030e9e423bdf372565d58e

PKG_MAINTAINER:=
PKG_LICENSE:=Vim
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:vim:vim

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/vim/Default
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libncurses
  TITLE:=Vi IMproved - enhanced vi editor
  URL:=https://www.vim.org/
  SUBMENU:=Editors
endef

define Package/vim
  $(call Package/vim/Default)
  TITLE+= (Tiny)
endef

define Package/vim-full
  $(call Package/vim/Default)
  TITLE+= (Normal)
  PROVIDES:=vim
  CONFLICTS:=vim
  DEPENDS:=+vim-runtime
  EXTRA_DEPENDS:=vim-runtime (=$(PKG_VERSION)-r$(PKG_RELEASE))
endef

define Package/vim-fuller
  $(call Package/vim/Default)
  TITLE+= (Huge)
  PROVIDES:=vim vim-full
  CONFLICTS:=vim vim-full
  DEPENDS:=+vim-runtime
  EXTRA_DEPENDS:=vim-runtime (=$(PKG_VERSION)-r$(PKG_RELEASE))
endef

define Package/vim-runtime
  $(call Package/vim/Default)
  TITLE+= (runtime files)
endef

define Package/vim-help
  $(call Package/vim/Default)
  TITLE+= (help files)
endef

define Package/xxd
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=make a hexdump or do the reverse
  URL:=https://www.vim.org/
  VERSION:=$(PKG_XXD_VERSION)-r$(PKG_RELEASE)
endef

define Package/vim/conffiles
/root/.vimrc
endef

Package/vim-full/conffiles = $(Package/vim/conffiles)
Package/vim-fuller/conffiles = $(Package/vim/conffiles)

define Package/vim/description/default
  Vim is an almost compatible version of the UNIX editor Vi.
endef

define Package/vim/description
  $(call Package/vim/description/default)
  Tiny build with minimal feature set.
endef

define Package/vim-full/description
  $(call Package/vim/description/default)
  Normal build with standard set of features like syntax highlighting, menus,
  mouse support, translations, spell checking, etc.
endef

define Package/vim-fuller/description
  $(call Package/vim/description/default)
  Huge build enables right-to-left language support, cscope, etc.
endef

define Package/vim-runtime/description
  $(call Package/vim/description/default)
  (Runtime files)
endef

define Package/vim-help/description
  $(call Package/vim/description/default)
  (Help files)
endef

define Package/xxd/description
  xxd creates a hex dump of a given file or standard input, it can also convert
  a hex dump back to its original binary form.
endef

CONFIGURE_ARGS += \
	--disable-acl \
	--disable-gtktest \
	--disable-libsodium \
	--disable-netbeans \
	--disable-selinux \
	--enable-gpm=no \
	--enable-gui=no \
	--with-compiledby="non-existent-hostname-compiled" \
	--with-tlib=ncurses \
	--with-wayland=no

CONFIGURE_VARS += \
	vim_cv_getcwd_broken=no \
	vim_cv_memmove_handles_overlap=yes \
	vim_cv_stat_ignores_slash=yes \
	vim_cv_terminfo=yes \
	vim_cv_tgetent=zero \
	vim_cv_toupper_broken=no

ifneq ($(HOST_OS),Linux)
  TARGET_PATH_PKG:=$(CURDIR)/scripts:$(TARGET_PATH_PKG)
endif

define Build/Prepare
	$(call Build/Prepare/Default)
	$(MAKE) -C $(PKG_BUILD_DIR)/src autoconf
endef

ifneq ($(CONFIG_PACKAGE_vim),)
define Build/Compile/vim
	$(call Build/Configure/Default, \
		--with-features=tiny \
	)
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)/vim_tiny" all
	$(CP) $(PKG_BUILD_DIR)/src/$(PKG_NAME) $(PKG_BUILD_DIR)/vim_tiny
endef
endif

ifneq ($(CONFIG_PACKAGE_vim-full),)
define Build/Compile/vim-full
	$(call Build/Configure/Default, \
		--with-features=normal \
	)
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)/vim_normal" all
	$(CP) $(PKG_BUILD_DIR)/src/$(PKG_NAME) $(PKG_BUILD_DIR)/vim_normal
endef
endif

ifneq ($(CONFIG_PACKAGE_vim-fuller),)
define Build/Compile/vim-fuller
	$(call Build/Configure/Default, \
		--with-features=huge \
	)
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)/vim_huge" all
	$(CP) $(PKG_BUILD_DIR)/src/$(PKG_NAME) $(PKG_BUILD_DIR)/vim_huge
endef
endif

ifneq ($(CONFIG_PACKAGE_xxd),)
define Build/Compile/xxd
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" all
endef
endif

define Build/Compile/vim-runtime
	$(MAKE) -C $(PKG_BUILD_DIR)/src DESTDIR="$(PKG_INSTALL_DIR)/vim_runtime" installrtbase
	(cd $(PKG_INSTALL_DIR)/vim_runtime && tar -cf $(PKG_BUILD_DIR)/docs.tar ./usr/share/vim/vim$(VIMVER)/doc)
	$(RM) -r $(PKG_INSTALL_DIR)/vim_runtime/usr/share/vim/vim$(VIMVER)/doc
	$(RM) -r $(PKG_INSTALL_DIR)/vim_runtime/usr/man
endef

define Build/Compile
$(call Build/Compile/vim)
$(call Build/Compile/vim-full)
$(call Build/Compile/vim-fuller)
$(call Build/Compile/vim-runtime)
$(call Build/Compile/xxd)
endef

define Package/vim/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/vim_tiny $(1)/usr/bin/vim
	$(INSTALL_DIR) $(1)/usr/share/vim
	$(INSTALL_CONF) ./files/defaults.vim $(1)/usr/share/vim
endef

define Package/vim-full/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/vim_normal $(1)/usr/bin/vim
	$(INSTALL_DIR) $(1)/usr/share/vim
	$(LN) vim $(1)/usr/bin/vimdiff
endef

define Package/vim-fuller/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/vim_huge $(1)/usr/bin/vim
	$(INSTALL_DIR) $(1)/usr/share/vim
	$(LN) vim $(1)/usr/bin/vimdiff
endef

define Package/vim-runtime/install
	$(CP) $(PKG_INSTALL_DIR)/vim_runtime/* $(1)
	$(INSTALL_DIR) $(1)/usr/share/vim/vim$(VIMVER)/pack/dist/opt/netrw
	$(RM) -r $(1)/usr/share/vim/vim$(VIMVER)/doc
endef

define Package/vim-help/install
	$(TAR) -C $(1) -xf $(PKG_BUILD_DIR)/docs.tar
endef

define Package/xxd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/xxd/xxd $(1)/usr/bin
endef

$(eval $(call BuildPackage,vim))
$(eval $(call BuildPackage,vim-full))
$(eval $(call BuildPackage,vim-fuller))
$(eval $(call BuildPackage,vim-runtime))
$(eval $(call BuildPackage,vim-help))
$(eval $(call BuildPackage,xxd))
