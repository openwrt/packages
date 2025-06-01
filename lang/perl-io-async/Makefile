include $(TOPDIR)/rules.mk

PKG_NAME:=perl-io-async
PKG_VERSION:=0.804
PKG_RELEASE:=1

PKG_SOURCE_NAME:=IO-Async
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/P/PE/PEVANS
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=90615432918164cd6f9e6dc2521195a4589606ffd017e03d5aa97f407d39c494
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-io-async
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Asynchronous event-driven programming for Perl
  URL:=https://metacpan.org/pod/Net::SSLeay
  DEPENDS:=perl +perlbase-essential +perlbase-file +perlbase-io +perlbase-list +perlbase-socket +perlbase-storable +perlbase-time +perlbase-encode +perlbase-experimental +perl-future +perl-struct-dumb
endef

define Package/perl-io-async/description
  This collection of modules allows programs to be written that perform
  asynchronous filehandle IO operations.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-io-async/install
	$(call perlmod/Install,$(1),IO Future)
endef

$(eval $(call BuildPackage,perl-io-async))

