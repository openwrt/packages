#
# Copyright (C) 2013-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-www
PKG_VERSION:=6.15
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/E/ET/ETHER/
PKG_SOURCE:=libwww-perl-$(PKG_VERSION).tar.gz
PKG_HASH:=6f349d45c21b1ec0501c4437dfcb70570940e6c3d5bff783bd91d4cddead8322

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
  DEPENDS:=perl +perl-encode-locale +perl-file-listing +perl-html-parser +perl-http-cookies +perl-http-daemon +perl-http-date +perl-http-message +perl-http-negotiate +perl-lwp-mediatypes +perl-net-http +perl-uri +perl-www-robotrules +perlbase-base +perlbase-digest +perlbase-encode +perlbase-essential +perlbase-io +perlbase-mime +perlbase-net
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-www/install
	$(call perlmod/Install,$(1),LWP.pm auto/LWP LWP)
endef


$(eval $(call BuildPackage,perl-www))
