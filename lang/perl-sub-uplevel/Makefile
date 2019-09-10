#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-sub-uplevel
PKG_VERSION:=0.25
PKG_RELEASE:=2

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/D/DA/DAGOLDEN
PKG_SOURCE:=Sub-Uplevel-$(PKG_VERSION).tar.gz
PKG_HASH:=2dcca582a7ea5bada576eb27c4be1d1b064fb22175bdbd6d696c45d083560505

PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/Sub-Uplevel-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-sub-uplevel
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Apparently run a function in a higher stack frame
  URL:=http://search.cpan.org/dist/Sub-Uplevel/
  DEPENDS:=perl +perlbase-essential
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-sub-uplevel/install
        $(call perlmod/Install,$(1),Sub auto/Sub)
endef


$(eval $(call BuildPackage,perl-sub-uplevel))
