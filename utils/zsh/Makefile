#
# Copyright (C) 2013-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zsh
PKG_VERSION:=5.4.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/zsh
PKG_HASH:=957bcdb2c57f64c02f673693ea5a7518ef24b6557aeb3a4ce222cefa6d74acc9
PKG_MAINTAINER:=Vadim A. Misbakh-Soloviov <openwrt-zsh@mva.name>
PKG_LICENSE:=ZSH

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/zsh
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Shells
  TITLE:=The Z shell
  DEPENDS:=+libcap +libncurses +libncursesw +libpcre +librt
  URL:=http://www.zsh.org/
endef

define Package/zsh/description
        Zsh is a UNIX command interpreter (shell) usable as an interactive
        login  shell  and  as a shell script command processor. Of the standard
        shells, zsh most closely resembles ksh but includes many enhancements.
        Zsh has command line editing, builtin spelling correction, programmable
        command completion, shell functions (with autoloading), a history
        mechanism, and a host of other features.
endef

define Build/Configure
	$(call Build/Configure/Default, \
		--disable-etcdir \
		--disable-gdbm \
		--enable-dynamic \
		--enable-libc-musl \
		--enable-pcre \
		--enable-cap \
		--enable-multibyte \
		--enable-unicode9 \
		--enable-runhelpdir=$(CONFIGURE_PREFIX)/share/zsh/$(PKG_VERSION)/help \
		--enable-fndir=$(CONFIGURE_PREFIX)/share/zsh/$(PKG_VERSION)/functions \
		--enable-site-fndir=$(CONFIGURE_PREFIX)/share/zsh/site-functions \
		--enable-function-subdirs \
		--with-tcsetpgrp \
		--with-term-lib="ncursesw", \
		zsh_cv_shared_environ=yes \
		zsh_cv_sys_dynamic_clash_ok=yes\
		zsh_cv_sys_dynamic_execsyms=yes \
		zsh_cv_sys_dynamic_rtld_global=yes \
		zsh_cv_sys_dynamic_strip_exe=yes \
		zsh_cv_sys_dynamic_strip_lib=yes \
		zsh_cv_sys_nis=no \
		zsh_cv_sys_nis_plus=no \
	)
	# Do not install these functions:
	$(SED) 's, Completion/AIX/\*/\*,,g' $(PKG_BUILD_DIR)/config.modules
	$(SED) 's, Completion/BSD/\*/\*,,g' $(PKG_BUILD_DIR)/config.modules
	$(SED) 's, Completion/Cygwin/\*/\*,,g' $(PKG_BUILD_DIR)/config.modules
	$(SED) 's, Completion/Darwin/\*/\*,,g' $(PKG_BUILD_DIR)/config.modules
	$(SED) 's, Completion/Debian/\*/\*,,g' $(PKG_BUILD_DIR)/config.modules
	$(SED) 's, Completion/Mandriva/\*/\*,,g' $(PKG_BUILD_DIR)/config.modules
	$(SED) 's, Completion/Redhat/\*/\*,,g' $(PKG_BUILD_DIR)/config.modules
	$(SED) 's, Completion/Solaris/\*/\*,,g' $(PKG_BUILD_DIR)/config.modules
	$(SED) 's, Completion/X/\*/\*,,g' $(PKG_BUILD_DIR)/config.modules
	$(SED) 's, Completion/openSUSE/\*/\*,,g' $(PKG_BUILD_DIR)/config.modules
	# After mucking with 'config.modules', one must call
	$(MAKE) -C $(PKG_BUILD_DIR) DESTDIR="$(PKG_INSTALL_DIR)" prep
endef

define Package/zsh/postinst
#!/bin/sh
grep zsh $${IPKG_INSTROOT}/etc/shells || \
	echo "/usr/bin/zsh" >> $${IPKG_INSTROOT}/etc/shells

	# Backwards compatibility
	if [[ -e /bin/zsh ]] && ([[ ! -L /bin/zsh ]] || [[ "$(readlink -fn $${IPKG_INSTROOT}/bin/zsh)" != "../$(CONFIGURE_PREFIX)/bin/zsh" ]]); then
		ln -fs "../$(CONFIGURE_PREFIX)/bin/zsh" "$${IPKG_INSTROOT}/bin/zsh"
	fi
endef

define Package/zsh/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_DIR) $(1)/$(CONFIGURE_PREFIX)/bin
	$(INSTALL_DIR) $(1)/$(CONFIGURE_PREFIX)/lib/zsh/$(PKG_VERSION)
	$(INSTALL_DIR) $(1)/$(CONFIGURE_PREFIX)/share/zsh/$(PKG_VERSION)

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/$(CONFIGURE_PREFIX)/bin/zsh $(1)/$(CONFIGURE_PREFIX)/bin/
	$(CP) $(PKG_INSTALL_DIR)/$(CONFIGURE_PREFIX)/lib/zsh/$(PKG_VERSION)/* $(1)/$(CONFIGURE_PREFIX)/lib/zsh/$(PKG_VERSION)/
	$(CP) $(PKG_INSTALL_DIR)/$(CONFIGURE_PREFIX)/share/zsh/$(PKG_VERSION)/* $(1)/$(CONFIGURE_PREFIX)/share/zsh/$(PKG_VERSION)/
endef

define Package/zsh/postrm
	rm -rf "$${IPKG_INSTROOT}/$(CONFIGURE_PREFIX)/share/zsh/$(PKG_VERSION)"
endef

$(eval $(call BuildPackage,zsh))
