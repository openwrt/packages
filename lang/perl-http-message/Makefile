#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-http-message
PKG_VERSION:=6.11
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/E/ET/ETHER
PKG_SOURCE:=HTTP-Message-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=4ed7add10daea3ab30abfeab6d03872f

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/HTTP-Message-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-http-message
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=HTTP style messages
  URL:=http://search.cpan.org/dist/HTTP-Message/
  DEPENDS:=perl +perl-encode-locale +perl-http-date +perl-io-html +perl-lwp-mediatypes +perl-uri +perlbase-base +perlbase-compress +perlbase-encode +perlbase-essential +perlbase-io +perlbase-mime
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-http-message/install
        $(call perlmod/Install,$(1),HTTP auto/HTTP)
endef


$(eval $(call BuildPackage,perl-http-message))
