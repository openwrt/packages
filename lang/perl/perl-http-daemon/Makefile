include $(TOPDIR)/rules.mk

PKG_NAME:=perl-http-daemon
PKG_VERSION:=6.16
PKG_RELEASE:=1

METACPAN_NAME:=HTTP-Daemon
METACPAN_AUTHOR:=OALDERS
PKG_HASH:=b38d092725e6fa4e0c4dc2a47e157070491bafa0dbe16c78a358e806aa7e173d

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-http-daemon
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A simple http server class
  URL:=https://metacpan.org/pod/HTTP::Daemon
  DEPENDS:=perl +perlbase-essential +perlbase-io +perlbase-socket +perl-http-date +perl-http-message +perl-lwp-mediatypes
endef

define Package/perl-http-daemon/description
  Instances of the HTTP::Daemon class are HTTP/1.1 servers
  that listen on a socket for incoming requests.
endef

define Build/Configure
    $(call perlmod/Configure,,)
endef

define Build/Compile
    $(call perlmod/Compile,,)
endef

define Package/perl-http-daemon/install
    $(call perlmod/Install,$(1),HTTP)
endef

$(eval $(call BuildPackage,perl-http-daemon))
