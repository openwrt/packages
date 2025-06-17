include $(TOPDIR)/rules.mk

PKG_NAME:=perl-http-date
PKG_VERSION:=6.06
PKG_RELEASE:=1

METACPAN_NAME:=HTTP-Date
METACPAN_AUTHOR:=OALDERS
PKG_HASH:=7b685191c6acc3e773d1fc02c95ee1f9fae94f77783175f5e78c181cc92d2b52

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-http-date
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Date conversion routines
  URL:=https://metacpan.org/pod/HTTP::Date
  DEPENDS:=perl +perlbase-essential +perlbase-time
endef

define Package/perl-http-date/description
  This module provides functions that deal the date formats
  used by the HTTP protocol.
endef

define Build/Configure
    $(call perlmod/Configure,,)
endef

define Build/Compile
    $(call perlmod/Compile,,)
endef

define Package/perl-http-date/install
    $(call perlmod/Install,$(1),HTTP)
endef

$(eval $(call BuildPackage,perl-http-date))
