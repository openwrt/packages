#
# Copyright (C) 2011-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=tcsh
PKG_VERSION:=6.18.01
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= \
	http://ftp.funet.fi/pub/mirrors/ftp.astron.com/pub/tcsh/ \
	http://ftp.funet.fi/pub/mirrors/ftp.astron.com/pub/tcsh/old/ \
	ftp://ftp.astron.com/pub/tcsh/ \
	ftp://ftp.astron.com/pub/tcsh/old
PKG_MD5SUM:=6eed09dbd4223ab5b6955378450d228a
PKG_LICENSE:=BSD-4-Clause-UC
PKG_LICENSE_FILES:=Copyright

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/tcsh
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Enhanced Berkeley UNIX C shell
  DEPENDS:=+libncurses
  URL:=http://www.tcsh.org/
endef

define Package/tcsh/description
	Tcsh is an enhanced, but completely compatible
	version of the Berkeley UNIX C shell (csh). It
	is a command language interpreter usable both
	as an interactive login shell and a shell
	script command processor. It includes a
	command-line editor, programmable word
	completion, spelling correction, a history
	mechanism, job control and a C-like syntax.
endef

define Package/tcsh/postinst
#!/bin/sh
grep tcsh $${IPKG_INSTROOT}/etc/shells || \
	echo "/bin/tcsh" >> $${IPKG_INSTROOT}/etc/shells
	echo "/bin/csh" >> $${IPKG_INSTROOT}/etc/shells
endef

define Package/tcsh/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tcsh $(1)/bin/
	ln -sf tcsh $(1)/bin/csh
endef

$(eval $(call BuildPackage,tcsh))
