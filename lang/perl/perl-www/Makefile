include $(TOPDIR)/rules.mk

PKG_NAME:=perl-www
PKG_VERSION:=6.78
PKG_RELEASE:=2

METACPAN_NAME:=libwww-perl
METACPAN_AUTHOR:=OALDERS
PKG_HASH:=b738bdcf54e2c6bb81fd2b83ec47bc83347f97b371ea80f0dc10360f817a9a44

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-www
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=The World-Wide Web library for Perl
  URL:=https://metacpan.org/pod/LWP
  DEPENDS:=perl +perlbase-base +perlbase-digest +perlbase-encode +perlbase-essential +perlbase-io +perlbase-mime +perlbase-module +perlbase-net +perl-encode-locale +perl-file-listing +perl-html-parser +perl-http-cookies +perl-http-daemon +perl-http-date +perl-http-message +perl-http-negotiate +perl-lwp-mediatypes +perl-net-http +perl-try-tiny +perl-uri +perl-www-robotrules
endef

define Package/perl-www/description
  The libwww-perl collection is a set of Perl modules
  which provides a simple and consistent application
  programming interface (API) to the World-Wide Web.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-www/install
	$(call perlmod/Install,$(1),LWP.pm LWP)
endef

$(eval $(call BuildPackage,perl-www))
