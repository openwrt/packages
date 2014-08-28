#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-www
PKG_VERSION:=5.837
PKG_RELEASE:=2

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/G/GA/GAAS/
PKG_SOURCE:=libwww-perl-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=9bbf1bce482b0bac98bb4f04253c03d0

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/libwww-perl-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-www
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=WWW client/server library for Perl (aka LWP)
  URL:=http://search.cpan.org/dist/libwww-perl/
  DEPENDS:=perl +perl-html-parser +perl-html-tagset +perl-uri
endef

define Build/Configure
	$(call perlmod/Configure,-n,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-www/install
	$(call perlmod/Install,$(1),File HTML HTTP LWP LWP.pm Net WWW)
endef


$(eval $(call BuildPackage,perl-www))
