include $(TOPDIR)/rules.mk

PKG_NAME:=perl-lwp-mediatypes
PKG_VERSION:=6.04
PKG_RELEASE:=2

METACPAN_NAME:=LWP-MediaTypes
METACPAN_AUTHOR:=OALDERS
PKG_HASH:=8f1bca12dab16a1c2a7c03a49c5e58cce41a6fec9519f0aadfba8dad997919d9

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-lwp-mediatypes
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Guess media type for a file or a URL
  URL:=https://metacpan.org/pod/LWP::MediaTypes
  DEPENDS:=perl +perlbase-essential +perlbase-file +perlbase-scalar
endef

define Package/perl-lwp-mediatypes/description
  This module provides functions for handling media
  (also known as MIME) types and encodings.
endef

define Build/Configure
    $(call perlmod/Configure,,)
endef

define Build/Compile
    $(call perlmod/Compile,,)
endef

define Package/perl-lwp-mediatypes/install
    $(call perlmod/Install,$(1),LWP)
endef

$(eval $(call BuildPackage,perl-lwp-mediatypes))
