include $(TOPDIR)/rules.mk

PKG_NAME:=perl-io-socket-ssl
PKG_VERSION:=2.094
PKG_RELEASE:=1

METACPAN_NAME:=IO-Socket-SSL
METACPAN_AUTHOR:=SULLR
PKG_HASH:=b2446889cb5e20545d782c4676da1b235673a81c181689aaae2492589d84bf02

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-io-socket-ssl
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Perl SSL sockets with IO::Socket interface
  URL:=https://metacpan.org/pod/Net::SSLeay
  DEPENDS:=perl +perlbase-autoloader +perlbase-io +perlbase-list +perl-net-ssleay
endef

define Package/perl-io-socket-ssl/description
  IO::Socket::SSL makes using SSL/TLS much easier by wrapping the
  functionality into the familiar IO::Socket interface and providing
  secure defaults whenever possible.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-io-socket-ssl/install
	$(call perlmod/Install,$(1),IO)
endef

$(eval $(call BuildPackage,perl-io-socket-ssl))
