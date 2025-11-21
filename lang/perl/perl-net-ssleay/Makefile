include $(TOPDIR)/rules.mk

PKG_NAME:=perl-net-ssleay
PKG_VERSION:=1.94
PKG_RELEASE:=1

PKG_SOURCE_NAME:=Net-SSLeay
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/C/CH/CHRISN
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=9d7be8a56d1bedda05c425306cc504ba134307e0c09bda4a788c98744ebcd95d
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-net-ssleay
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Perl bindings for OpenSSL and LibreSSL
  URL:=https://metacpan.org/pod/Net::SSLeay
  DEPENDS:=perl +perlbase-essential +perlbase-mime +libopenssl +zlib
endef

define Package/perl-net-ssleay/description
  This module provides Perl bindings for libssl (an SSL/TLS API)
  and libcrypto (a cryptography API).
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-net-ssleay/install
	$(call perlmod/Install,$(1),Net auto/Net)
endef

$(eval $(call BuildPackage,perl-net-ssleay))

