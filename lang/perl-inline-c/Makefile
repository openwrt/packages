#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-inline-c
PKG_VERSION:=0.78
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/T/TI/TINITA
PKG_SOURCE:=Inline-C-$(PKG_VERSION).tar.gz
PKG_HASH:=9a7804d85c01a386073d2176582b0262b6374c5c0341049da3ef84c6f53efbc7

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/perl/Inline-C-$(PKG_VERSION)
HOST_BUILD_DEPENDS:=perl/host perl-inline/host perl-parse-recdescent/host perl-file-sharedir-install/host
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/Inline-C-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=perl-inline/host perl-parse-recdescent/host perl-file-sharedir-install/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../perl/perlmod.mk

define Package/perl-inline-c
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=C Language Support for Inline
  URL:=http://search.cpan.org/dist/Inline-C/
  DEPENDS:=perl +perl-inline +perl-parse-recdescent +perlbase-config +perlbase-cwd +perlbase-data +perlbase-essential +perlbase-file +perlbase-if
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

define Package/perl-inline-c/install
        $(call perlmod/Install,$(1),Inline auto/Inline)
endef


$(eval $(call BuildPackage,perl-inline-c))
$(eval $(call HostBuild))
