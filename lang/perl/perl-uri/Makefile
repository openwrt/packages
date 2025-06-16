include $(TOPDIR)/rules.mk

PKG_NAME:=perl-uri
PKG_VERSION:=5.32
PKG_RELEASE:=1

METACPAN_NAME:=URI
METACPAN_AUTHOR:=OALDERS
PKG_HASH:=9632067d34e14e0dae2da94631c4f25a387fcc48d06fa29330e8b3c04c4e913d

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-uri
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Manipulates and accesses URI strings
  URL:=https://metacpan.org/pod/URI
  DEPENDS:=perl +perlbase-essential +perlbase-integer +perlbase-mime +perlbase-scalar +perlbase-utf8
endef

define Package/perl-uri/description
  This module implements the URI class. Objects of this class represent
  Uniform Resource Identifier references as specified in RFCs 2396/2732
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-uri/install
	$(call perlmod/Install,$(1),URI URI.pm)
endef

$(eval $(call BuildPackage,perl-uri))
