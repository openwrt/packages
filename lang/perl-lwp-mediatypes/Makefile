#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-lwp-mediatypes
PKG_VERSION:=6.02
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/G/GA/GAAS
PKG_SOURCE:=LWP-MediaTypes-$(PKG_VERSION).tar.gz
PKG_HASH:=18790b0cc5f0a51468495c3847b16738f785a2d460403595001e0b932e5db676

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/LWP-MediaTypes-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-lwp-mediatypes
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Guess media type for a file or a URL
  URL:=http://search.cpan.org/dist/LWP-MediaTypes/
  DEPENDS:=perl +perlbase-essential
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-lwp-mediatypes/install
        $(call perlmod/Install,$(1),LWP auto/LWP)
endef


$(eval $(call BuildPackage,perl-lwp-mediatypes))
