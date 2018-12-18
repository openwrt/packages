#
# Copyright (C) 2017 Philip Prindeville, Redfish Solutions, LLC
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-text-csv_xs
PKG_VERSION:=1.37
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.cpan.org/authors/id/H/HM/HMBRAND/
PKG_SOURCE:=Text-CSV_XS-$(PKG_VERSION).tgz
PKG_HASH:=20e16da9c38b0938f308c01d954f49d2c6922bac0d2d979bf2ad483fe7476ba2

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_MAINTAINER:=Philip Prindeville <philipp@redfish-solutions.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/Text-CSV_XS-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-text-csv_xs
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Text comma-separated values manipulation routines
  URL:=http://search.cpan.org/dist/Text-CSV_XS/
  DEPENDS:=perl +perlbase-essential +perlbase-config +perlbase-io +perlbase-dynaloader
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-text-csv_xs/install
        $(call perlmod/Install,$(1),Text Text/CSV_XS.pm auto/Text/CSV_XS)
endef


$(eval $(call BuildPackage,perl-text-csv_xs))
