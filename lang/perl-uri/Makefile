#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-uri
PKG_VERSION:=1.67
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/E/ET/ETHER/
PKG_SOURCE:=URI-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=d0ef53b6c63bcc02ba55f405c30741e3

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/URI-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-uri
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Manipulates and accesses URI strings
  URL:=http://search.cpan.org/dist/URI/
  DEPENDS:=perl
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-uri/install
	$(call perlmod/Install,$(1),URI URI.pm)
endef


$(eval $(call BuildPackage,perl-uri))
