#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-io-html
PKG_VERSION:=1.001
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/C/CJ/CJM
PKG_SOURCE:=IO-HTML-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=3f8958718844dc96b9f6946f21d70d22

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/IO-HTML-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-io-html
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Open an HTML file with automatic charset detection
  URL:=http://search.cpan.org/dist/IO-HTML/
  DEPENDS:=perl +perlbase-encode +perlbase-essential
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-io-html/install
        $(call perlmod/Install,$(1),IO auto/IO)
endef


$(eval $(call BuildPackage,perl-io-html))
