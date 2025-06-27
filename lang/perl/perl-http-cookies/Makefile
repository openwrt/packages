include $(TOPDIR)/rules.mk

PKG_NAME:=perl-http-cookies
PKG_VERSION:=6.11
PKG_RELEASE:=1

METACPAN_NAME:=HTTP-Cookies
METACPAN_AUTHOR:=OALDERS
PKG_HASH:=8c9a541a4a39f6c0c7e3d0b700b05dfdb830bd490a1b1942a7dedd1b50d9a8c8

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-http-cookies
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=HTTP cookie jars
  URL:=https://metacpan.org/pod/HTTP::Cookies
  DEPENDS:=perl +perlbase-essential +perlbase-time +perl-http-date +perl-http-message
endef

define Package/perl-http-cookies/description
  This class is for objects that represent a database
  of all the HTTP cookies that a given LWP::UserAgent
  object knows about.
endef

define Build/Configure
    $(call perlmod/Configure,,)
endef

define Build/Compile
    $(call perlmod/Compile,,)
endef

define Package/perl-http-cookies/install
    $(call perlmod/Install,$(1),HTTP)
endef

$(eval $(call BuildPackage,perl-http-cookies))
