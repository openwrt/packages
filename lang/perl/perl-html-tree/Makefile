include $(TOPDIR)/rules.mk

PKG_NAME:=perl-html-tree
PKG_VERSION:=5.07
PKG_RELEASE:=1

METACPAN_NAME:=HTML-Tree
METACPAN_AUTHOR:=KENTNL
PKG_HASH:=f0374db84731c204b86c1d5b90975fef0d30a86bd9def919343e554e31a9dbbf

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-html-tree
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Build and scan parse-trees of HTML
  URL:=https://metacpan.org/pod/HTML::Tree
  DEPENDS:=perl +perlbase-essential +perlbase-integer +perlbase-scalar +perl-html-parser +perl-html-tagset
endef

define Package/perl-html-tree/description
  HTML-Tree is a suite of Perl modules for making
  parse trees out of HTML source.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-html-tree/install
	$(call perlmod/Install,$(1),HTML)
endef

$(eval $(call BuildPackage,perl-html-tree))
