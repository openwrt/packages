#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-parse-recdescent
PKG_VERSION:=1.967013
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/J/JT/JTBRAUN
PKG_SOURCE:=Parse-RecDescent-$(PKG_VERSION).tar.gz
PKG_HASH:=226590d3850cd1678deb0190d5207b3477fb9070a8ca6f18d8999daf44485930

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/perl/Parse-RecDescent-$(PKG_VERSION)
HOST_BUILD_DEPENDS:=perl/host
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/Parse-RecDescent-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../perl/perlmod.mk

define Package/perl-parse-recdescent
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Generate Recursive-Descent Parsers
  URL:=http://search.cpan.org/dist/Parse-RecDescent/
  DEPENDS:=perl +perlbase-essential +perlbase-test +perlbase-text
endef

define Host/Configure
        $(call perlmod/host/Configure,,,)
endef

define Host/Compile
        $(call perlmod/host/Compile,,)
endef

define Host/Install
        $(call perlmod/host/Install,$(1),)
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-parse-recdescent/install
        $(call perlmod/Install,$(1),Parse auto/Parse)
endef


$(eval $(call BuildPackage,perl-parse-recdescent))
$(eval $(call HostBuild))
