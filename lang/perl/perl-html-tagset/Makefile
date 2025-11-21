include $(TOPDIR)/rules.mk

PKG_NAME:=perl-html-tagset
PKG_VERSION:=3.24
PKG_RELEASE:=1

METACPAN_NAME:=HTML-Tagset
METACPAN_AUTHOR:=PETDANCE
PKG_HASH:=eb89e145a608ed1f8f141a57472ee5f69e67592a432dcd2e8b1dbb445f2b230b

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=Artistic-2.0

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-html-tagset
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Data tables useful in parsing HTML
  URL:=https://metacpan.org/pod/HTML::Tagset
  DEPENDS:=perl +perlbase-essential
endef

define Package/perl-html-tagset/description
  This module contains several data tables useful in
  various kinds of HTML parsing operations.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-html-tagset/install
	$(call perlmod/Install,$(1),HTML)
endef

$(eval $(call BuildPackage,perl-html-tagset))
