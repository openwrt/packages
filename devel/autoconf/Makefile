#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=autoconf
PKG_VERSION:=2.69
PKG_RELEASE:=2

PKG_SOURCE_URL:=@GNU/autoconf
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MD5SUM:=50f97f4159805e374639a73e2636f22e
PKG_MAINTAINER:=Heinrich Schuchardt <xypron.glpk@gmx.de>
PKG_LICENSE:=GPL-3.0+

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_VARS += M4=m4 EMACS=no

define Package/autoconf
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=autoconf
  URL:=https://www.gnu.org/software/autoconf/
  DEPENDS:=+m4 +perl +perlbase-data +perlbase-file +perlbase-getopt \
  +perlbase-dynaloader +perlbase-text
endef

define Package/autoconf/description
  Autoconf is an extensible package of M4 macros that produce shell scripts to
  automatically configure software source code packages.
endef

define Build/Install
	$(SED) 's/@PERL@/\/usr\/bin\/perl/g' $(PKG_BUILD_DIR)/bin/Makefile.in
	$(call Build/Install/Default)
endef

define Package/autoconf/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/autoconf
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/autoconf/INSTALL \
	$(1)/usr/share/autoconf/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/autoconf/autom4te.cfg \
	$(1)/usr/share/autoconf/
	$(INSTALL_DIR) $(1)/usr/share/autoconf/Autom4te
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/autoconf/Autom4te/* \
	$(1)/usr/share/autoconf/Autom4te/
	$(INSTALL_DIR) $(1)/usr/share/autoconf/autoconf
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/autoconf/autoconf/* \
	$(1)/usr/share/autoconf/autoconf/
	$(INSTALL_DIR) $(1)/usr/share/autoconf/autoscan
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/autoconf/autoscan/* \
	$(1)/usr/share/autoconf/autoscan/
	$(INSTALL_DIR) $(1)/usr/share/autoconf/autotest
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/autoconf/autotest/* \
	$(1)/usr/share/autoconf/autotest/
	$(INSTALL_DIR) $(1)/usr/share/autoconf/m4sugar
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/autoconf/m4sugar/* \
	$(1)/usr/share/autoconf/m4sugar/
endef

$(eval $(call BuildPackage,autoconf))
