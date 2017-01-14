#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-cgi
PKG_VERSION:=4.35
PKG_RELEASE:=2

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/L/LE/LEEJO
PKG_SOURCE:=CGI-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=15e63942c02354426b25f056f2a4467c

PKG_LICENSE:=GPL Artistic-2.0
PKG_MAINTAINER:=Marcel Denia <naoir@gmx.net>, \
		Philip Prindeville <philipp@redfish-solutions.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/CGI-$(PKG_VERSION)

# don't strip comments because that will mangle this module
PKG_LEAVE_COMMENTS:=1

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-cgi
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Handle Common Gateway Interface requests and responses
  URL:=http://search.cpan.org/dist/CGI/
  DEPENDS:=perl +perl-html-parser +perlbase-base +perlbase-config +perlbase-encode +perlbase-essential +perlbase-file +perlbase-if +perlbase-utf8
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-cgi/install
        $(call perlmod/Install,$(1),CGI CGI.pm auto/CGI)
endef


$(eval $(call BuildPackage,perl-cgi))
