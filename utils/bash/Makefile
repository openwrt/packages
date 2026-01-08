#
# Copyright (C) 2007-2026 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bash
PKG_VERSION:=5.3
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/bash
PKG_HASH:=0d5cd86965f869a26cf64f4b71be7b96f90a3ba8b3d74e27e8e9d9d5550f31ba

PKG_MAINTAINER:=Wei-Ting Yang <williamatcg@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:gnu:bash

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/bash
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Shells
  TITLE:=The GNU Bourne Again SHell
  DEPENDS:=+libncurses +libreadline
  URL:=https://www.gnu.org/software/bash/
endef

define Package/bash/description
  Bash is an sh-compatible command language interpreter that executes
  commands read from the standard input or from a file. Bash also
  incorporates useful features from the Korn and C shells (ksh and csh).
endef

define Package/bash/conffiles
/etc/bash.bashrc
/etc/bash.bash_logout
/etc/profile.d/sys_bashrc.sh
endef

# Bash detects and enables certain features by runtest simple piece of code
# which is not viable when doing cross compilation and default to no in many
# cases.  Grep for 'cross.compil' in aclocal.m4 and config-bot.h for details
#
# bash_cv_dev_fd: The test is done on build system but OpenWrt currently does
# not have /dev/fd, it provides /proc/self/fd/ instead
#
# bash_cv_getcwd_malloc: The replacement by bash does not work well with
# overlayfs.  See "bash getcwd errors when running under OverlayFS"
# http://permalink.gmane.org/gmane.linux.embedded.yocto.general/25204
#
# bash_cv_job_control_missing: Job control is needed for bash to be used as the
# default shell
#
# bash_cv_sys_named_pipes: Required for process substituion
CONFIGURE_VARS += \
	CFLAGS_FOR_BUILD="-std=gnu17" \
	ac_cv_rl_prefix="$(STAGING_DIR)/usr" \
	ac_cv_rl_version="8.0" \
	bash_cv_dev_fd=whacky \
	bash_cv_func_sigsetjmp=present \
	bash_cv_getcwd_malloc=yes \
	bash_cv_job_control_missing=present \
	bash_cv_printf_a_format=yes \
	bash_cv_sys_named_pipes=present

CONFIGURE_ARGS += \
	--bindir=/bin \
	--disable-rpath \
	--enable-direxpand-default \
	--enable-job-control \
	--enable-readline \
	--with-curses \
	--without-bash-malloc

TARGET_CFLAGS += -std=gnu17

define Package/bash/postinst
#!/bin/sh
grep -q bash "$${IPKG_INSTROOT}/etc/shells" || {
	echo /bin/bash >> "$${IPKG_INSTROOT}/etc/shells"
	echo /bin/rbash >> "$${IPKG_INSTROOT}/etc/shells"
}
endef

define Package/bash/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/bash $(1)/bin/
	$(LN) bash $(1)/bin/rbash
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,bash))
