#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-net-http
PKG_VERSION:=6.09
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/E/ET/ETHER
PKG_SOURCE:=Net-HTTP-$(PKG_VERSION).tar.gz
PKG_HASH:=52762b939d84806908ba544581c5708375f7938c3c0e496c128ca3fbc425e58d

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/Net-HTTP-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-net-http
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Low-level HTTP connection (client)
  URL:=http://search.cpan.org/dist/Net-HTTP/
  DEPENDS:=perl +perl-uri +perlbase-compress +perlbase-essential +perlbase-io
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-net-http/install
        $(call perlmod/Install,$(1),Net auto/Net)
endef


$(eval $(call BuildPackage,perl-net-http))
