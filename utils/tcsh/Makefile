#
# Copyright (C) 2011-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=tcsh
PKG_VERSION:=6.22.04
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= \
	https://astron.com/pub/tcsh/ \
	https://astron.com/pub/tcsh/old \
	https://ftp.funet.fi/pub/mirrors/ftp.astron.com/pub/tcsh \
	https://ftp.funet.fi/pub/mirrors/ftp.astron.com/pub/tcsh/old
PKG_HASH:=eb16356243218c32f39e07258d72bf8b21e62ce94bb0e8a95e318b151397e231

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=Copyright
PKG_CPE_ID:=cpe:/a:tcsh:tcsh

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=tcsh/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/tcsh
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Shells
  TITLE:=Enhanced Berkeley UNIX C shell
  DEPENDS:= +USE_GLIBC:libcrypt-compat +libncurses $(ICONV_DEPENDS)
  URL:=https://www.tcsh.org/
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


define Host/Compile
	$(call Host/Compile/Default,gethost)
endef

define Host/Install
	mkdir -p $(STAGING_DIR_HOSTPKG)/usr/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/gethost $(STAGING_DIR_HOSTPKG)/usr/bin/tcsh-gethost
endef

define Build/Compile
	#Build sh.err.h and tc.const.h for target build
	$(call Build/Compile/Default,sh.err.h)
	$(call Build/Compile/Default,tc.const.h)
	#Copy gethost (host tool to generate header file) from hostpkg dir
	$(CP) $(STAGING_DIR_HOSTPKG)/usr/bin/tcsh-gethost $(PKG_BUILD_DIR)/gethost
	#Make-touch header generator binary to prevent recompiling during target build
	$(call Build/Compile/Default,-t gethost)
	#Build tcsh for target
	$(call Build/Compile/Default)
endef

define Package/tcsh/postinst
#!/bin/sh
grep tcsh $${IPKG_INSTROOT}/etc/shells || { \
	echo "/bin/tcsh"
	echo "/bin/csh"
} >> $${IPKG_INSTROOT}/etc/shells
endef

define Package/tcsh/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tcsh $(1)/bin/
	ln -sf tcsh $(1)/bin/csh
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,tcsh))
