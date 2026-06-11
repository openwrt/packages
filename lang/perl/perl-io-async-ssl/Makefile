include $(TOPDIR)/rules.mk

PKG_NAME:=perl-io-async-ssl
PKG_VERSION:=0.25
PKG_RELEASE:=1

PKG_SOURCE_NAME:=IO-Async-SSL
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/P/PE/PEVANS
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=4def485db1eff4e139b4b5912202c0fd61c3aed2cec35bd5ab8bf7bbd83f5a75
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-io-async-ssl
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=SSL/TLS with IO::Async
  URL:=https://metacpan.org/pod/IO::Async::SSL
  DEPENDS:=perl +perlbase-io +perl-future +perl-io-async
endef

define Package/perl-io-async-ssl/description
  This module extends existing IO::Async classes with extra methods to
  allow the use of SSL or TLS-based connections using IO::Socket::SSL.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-io-async-ssl/install
	$(call perlmod/Install,$(1),IO)
endef

$(eval $(call BuildPackage,perl-io-async-ssl))
