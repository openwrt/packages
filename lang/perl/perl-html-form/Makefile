include $(TOPDIR)/rules.mk

PKG_NAME:=perl-html-form
PKG_VERSION:=6.12
PKG_RELEASE:=1

METACPAN_NAME:=HTML-Form
METACPAN_AUTHOR:=OALDERS
PKG_HASH:=2ced87d0878afa007d22c41927f0e8da63844608f20881f645f364dc32cdce6f

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-html-form
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Class that represents an HTML form element
  URL:=https://metacpan.org/pod/HTML::Form
  DEPENDS:=perl +perlbase-encode +perlbase-essential +perl-html-parser +perl-http-message +perl-uri
endef

define Package/perl-html-form/description
  Objects of the HTML::Form class represents a single HTML
  <form> ... </form> instance.
endef

define Build/Configure
    $(call perlmod/Configure,,)
endef

define Build/Compile
    $(call perlmod/Compile,,)
endef

define Package/perl-html-form/install
    $(call perlmod/Install,$(1),HTML)
endef

$(eval $(call BuildPackage,perl-html-form))
