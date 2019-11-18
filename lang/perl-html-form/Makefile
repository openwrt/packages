#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-html-form
PKG_VERSION:=6.05
PKG_RELEASE:=1

PKG_SOURCE:=HTML-Form-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/O/OA/OALDERS
PKG_HASH:=36c6c601ca829719f6651be1b80872028f82bec1712608dd860deeb67da32492
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/HTML-Form-$(PKG_VERSION)

PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-html-form
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Class that represents an HTML form element
  URL:=https://search.cpan.org/dist/HTML-Form/
  DEPENDS:=perl +perl-html-parser +perl-http-message +perl-uri +perlbase-encode +perlbase-essential
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-html-form/install
        $(call perlmod/Install,$(1),HTML auto/HTML)
endef


$(eval $(call BuildPackage,perl-html-form))
