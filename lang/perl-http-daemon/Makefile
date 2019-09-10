#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-http-daemon
PKG_VERSION:=6.01
PKG_RELEASE:=2

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/G/GA/GAAS
PKG_SOURCE:=HTTP-Daemon-$(PKG_VERSION).tar.gz
PKG_HASH:=43fd867742701a3f9fcc7bd59838ab72c6490c0ebaf66901068ec6997514adc2

PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/HTTP-Daemon-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-http-daemon
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A simple http server class
  URL:=http://search.cpan.org/dist/HTTP-Daemon/
  DEPENDS:=perl +perl-http-date +perl-http-message +perl-lwp-mediatypes +perlbase-essential +perlbase-io +perlbase-sys
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-http-daemon/install
        $(call perlmod/Install,$(1),HTTP auto/HTTP)
endef


$(eval $(call BuildPackage,perl-http-daemon))
