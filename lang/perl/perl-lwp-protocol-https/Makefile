include $(TOPDIR)/rules.mk

PKG_NAME:=perl-lwp-protocol-https
PKG_VERSION:=6.14
PKG_RELEASE:=1

METACPAN_NAME:=LWP-Protocol-https
METACPAN_AUTHOR:=OALDERS
PKG_HASH:=59cdeabf26950d4f1bef70f096b0d77c5b1c5a7b5ad1b66d71b681ba279cbb2a

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-lwp-protocol-https
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=https support for LWP::UserAgent
  URL:=https://metacpan.org/pod/LWP::Protocol::https
  DEPENDS:=perl +perlbase-essential +perl-io-socket-ssl +perl-www +perl-net-http
endef

define Package/perl-lwp-protocol-https/description
  The LWP::Protocol::https module provides support for using
  https schemed URLs with LWP::UserAgent
endef

define Build/Configure
    $(call perlmod/Configure,,)
endef

define Build/Compile
    $(call perlmod/Compile,,)
endef

define Package/perl-lwp-protocol-https/install
    $(call perlmod/Install,$(1),LWP)
endef

$(eval $(call BuildPackage,perl-lwp-protocol-https))
