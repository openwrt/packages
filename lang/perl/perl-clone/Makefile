include $(TOPDIR)/rules.mk

PKG_NAME:=perl-clone
PKG_VERSION:=0.47
PKG_RELEASE:=1

METACPAN_NAME:=Clone
METACPAN_AUTHOR:=ATOOMIC
PKG_HASH:=4c2c0cb9a483efbf970cb1a75b2ca75b0e18cb84bcb5c09624f86e26b09c211d

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-clone
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Recursively copy Perl datatypes
  URL:=https://metacpan.org/pod/Clone
  DEPENDS:=perl +perlbase-autoloader +perlbase-essential +perlbase-xsloader
endef

define Package/perl-clone/description
  This module provides a clone() method to make recursive copies.
endef

define Build/Configure
    $(call perlmod/Configure,,)
endef

define Build/Compile
    $(call perlmod/Compile,,)
endef

define Package/perl-clone/install
    $(call perlmod/Install,$(1),Clone.pm auto/Clone)
endef

$(eval $(call BuildPackage,perl-clone))
