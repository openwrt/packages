include $(TOPDIR)/rules.mk

PKG_NAME:=perl-io-socket-ssl
PKG_VERSION:=2.090
PKG_RELEASE:=1

PKG_SOURCE_NAME:=IO-Socket-SSL
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/S/SU/SULLR
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=fdda17888df9f88251b62856f17fcac8f144858c72d7e01d1c4b437d23383d97
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

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

