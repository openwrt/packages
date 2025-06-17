include $(TOPDIR)/rules.mk

PKG_NAME:=perl-http-message
PKG_VERSION:=7.00
PKG_RELEASE:=1

METACPAN_NAME:=HTTP-Message
METACPAN_AUTHOR:=OALDERS
PKG_HASH:=5afa95eb6ed1c632e81656201a2738e2c1bc6cbfae2f6d82728e2bb0b519c1dc

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-http-message
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=HTTP style messages
  URL:=https://metacpan.org/pod/HTTP::Message
  DEPENDS:=perl +perlbase-base +perlbase-compress +perlbase-encode +perlbase-essential +perlbase-io +perlbase-mime +perl-clone +perl-encode-locale +perl-http-date +perl-io-html +perl-lwp-mediatypes +perl-uri
endef

define Package/perl-http-message/description
  An HTTP::Message object contains some headers and a content body.
endef

define Build/Configure
    $(call perlmod/Configure,,)
endef

define Build/Compile
    $(call perlmod/Compile,,)
endef

define Package/perl-http-message/install
    $(call perlmod/Install,$(1),HTTP)
endef

$(eval $(call BuildPackage,perl-http-message))
