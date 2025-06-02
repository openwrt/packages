include $(TOPDIR)/rules.mk

PKG_NAME:=perl-net-async-http
PKG_VERSION:=0.50
PKG_RELEASE:=1

PKG_SOURCE_NAME:=Net-Async-HTTP
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/P/PE/PEVANS
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=92845b8ffdd2dc81decbe8a7b99203e4e34971de6624acb5c10aa9ff07885b87
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-net-async-http
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=HTTP with IO::Async
  URL:=https://metacpan.org/pod/Net::Async::HTTP
  DEPENDS:=perl +perlbase-list +perlbase-socket +perlbase-time +perl-future +perl-http-message +perl-io-async +perl-metrics-any +perl-struct-dumb +perl-uri
endef

define Package/perl-net-async-http/description
  This object class implements an asynchronous HTTP user agent.
  Similar to LWP::UserAgent, but for IO::Async.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-net-async-http/install
	$(call perlmod/Install,$(1),Net)
endef

$(eval $(call BuildPackage,perl-net-async-http))
