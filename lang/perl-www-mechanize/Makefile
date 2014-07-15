#
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-www-mechanize
PKG_VERSION:=1.58
PKG_RELEASE:=1

PKG_SOURCE:=WWW-Mechanize-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://search.cpan.org/CPAN/authors/id/P/PE/PETDANCE/
PKG_MD5SUM:=c928d1bf3218bfe0c0d99096cf34db52

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/WWW-Mechanize-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-www-mechanize
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Perl WWW Mechanize
  URL:=http://search.cpan.org/dist/WWW-Mechanize/
  DEPENDS:=perl +perl-www
endef

define Build/Configure
	$(call perlmod/Configure,$(STAGING_DIR)/usr/include,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-www-mechanize/install
	$(call perlmod/Install,$(1),WWW/Mechanize WWW/Mechanize.pm)
endef

$(eval $(call BuildPackage,perl-www-mechanize))
