#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-test-warn
PKG_VERSION:=0.30
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/C/CH/CHORNY
PKG_SOURCE:=Test-Warn-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=8306b998a96d2cc69266b5248d550472

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/Test-Warn-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-test-warn
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Perl extension to test methods for warnings
  URL:=http://search.cpan.org/dist/Test-Warn/
  DEPENDS:=perl +perl-sub-uplevel +perlbase-essential +perlbase-test
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-test-warn/install
        $(call perlmod/Install,$(1),Test auto/Test)
endef


$(eval $(call BuildPackage,perl-test-warn))
