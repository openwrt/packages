include $(TOPDIR)/rules.mk

PKG_NAME:=perl-www-mechanize
PKG_VERSION:=2.19
PKG_RELEASE:=1

METACPAN_NAME:=WWW-Mechanize
METACPAN_AUTHOR:=OALDERS
PKG_HASH:=7b02e808018ff22a8798e51b5f329d8fac333fbfa8fb63808910091dade8b61f

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-www-mechanize
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Handy web browsing in a Perl object
  URL:=https://metacpan.org/pod/WWW::Mechanize
  DEPENDS:=perl +perlbase-base +perlbase-essential +perlbase-file +perlbase-findbin +perlbase-getopt +perlbase-pod +perlbase-test +perl-cgi +perl-html-form +perl-html-parser +perl-html-tree +perl-http-daemon +perl-http-message +perl-http-server-simple +perl-test-warn +perl-uri +perl-www
endef

define Package/perl-www-mechanize/description
  WWW::Mechanize supports performing a sequence of page
  fetches including following links and submitting forms.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-www-mechanize/install
	$(call perlmod/Install,$(1),WWW)
endef

$(eval $(call BuildPackage,perl-www-mechanize))
