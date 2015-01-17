#
# Copyright (C) 2014, 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-dbi
PKG_VERSION:=1.633
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/T/TI/TIMB/
PKG_SOURCE:=DBI-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=b4fe13b9a51c1446c5f3cf93e69a2044

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/DBI-$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/perl/DBI-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../perl/perlmod.mk

define Package/perl-dbi
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Database independent interface for Perl
  URL:=http://search.cpan.org/dist/DBI/
  DEPENDS:=perl +perlbase-essential
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Host/Configure
	$(call perlmod/host/Configure,,)
endef

define Host/Compile
	$(call perlmod/host/Compile,,)
endef

define Host/Install
	$(call perlmod/host/Install,$(1),)
endef

define Package/perl-dbi/install
	$(call perlmod/Install,$(1),DB* auto/DBI,DBI/W32ODBC.pm auto/DBI/*.h)
endef


$(eval $(call BuildPackage,perl-dbi))
$(eval $(call HostBuild))
