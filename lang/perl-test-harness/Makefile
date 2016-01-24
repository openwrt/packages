#
# Copyright (C) 2014 - 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-test-harness
PKG_VERSION:=3.36
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/L/LE/LEONT/
PKG_SOURCE:=Test-Harness-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=4c8d9c77e8e06ca96c7383c05c8f3616

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/Test-Harness-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-test-harness
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Perl Test Harness
  URL:=http://search.cpan.org/dist/Test-Harness/
  DEPENDS:=perl +perlbase-base +perlbase-benchmark +perlbase-config +perlbase-essential +perlbase-file +perlbase-getopt +perlbase-io +perlbase-posix +perlbase-text
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-test-harness/install
	$(call perlmod/Install,$(1),App auto/Test TAP Test)
endef


$(eval $(call BuildPackage,perl-test-harness))
