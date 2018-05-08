#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bash
PKG_VERSION:=4.4.18
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/bash
PKG_HASH:=604d9eec5e4ed5fd2180ee44dd756ddca92e0b6aa4217bbab2b6227380317f23
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/bash
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Shells
  TITLE:=The GNU Bourne Again SHell
  DEPENDS:=+libncurses +libreadline
  URL:=http://www.gnu.org/software/bash/
endef

define Package/bash/description
  Bash is an sh-compatible command language interpreter that executes
  commands read from the standard input or from a file. Bash also
  incorporates useful features from the Korn and C shells (ksh and csh).
endef

CONFIGURE_VARS += \
	ac_cv_rl_prefix="$(STAGING_DIR)/usr" \
	ac_cv_rl_version="7.0" \
	bash_cv_getcwd_malloc=yes \
	bash_cv_job_control_missing=present \
	bash_cv_sys_named_pipes=present \
	bash_cv_func_sigsetjmp=present \
	bash_cv_printf_a_format=yes

CONFIGURE_ARGS+= \
	--without-bash-malloc \
	--bindir=/bin \
	--disable-rpath \
	--with-curses \
	--with-installed-readline="$(STAGING_DIR)/usr"

define Package/bash/postinst
#!/bin/sh
grep bash $${IPKG_INSTROOT}/etc/shells || \
	echo "/bin/bash" >> $${IPKG_INSTROOT}/etc/shells
	echo "/bin/rbash" >> $${IPKG_INSTROOT}/etc/shells
endef

define Package/bash/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/bash $(1)/bin/
	ln -sf bash $(1)/bin/rbash
endef


$(eval $(call BuildPackage,bash))
