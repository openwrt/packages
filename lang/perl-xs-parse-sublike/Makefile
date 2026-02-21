include $(TOPDIR)/rules.mk

PKG_NAME:=perl-xs-parse-sublike
PKG_VERSION:=0.37
PKG_RELEASE:=1

PKG_SOURCE_NAME:=XS-Parse-Sublike
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/P/PE/PEVANS
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=736528c888ea7b6a6191011e5d5a7824ec38a5620507de6ef45e4bc6e1cf0da9
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-xs-parse-sublike
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=XS functions to assist in parsing sub-like syntax
  URL:=https://metacpan.org/pod/XS::Parse::Sublike
  DEPENDS:=perl +perlbase-essential +perlbase-xsloader
endef

define Package/perl-xs-parse-sublike/description
  This module provides some XS functions to assist in writing parsers for
  sub-like syntax, primarily for authors of keyword plugins using the
  PL_keyword_plugin hook mechanism.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-xs-parse-sublike/install
	$(call perlmod/Install,$(1),Sublike XS auto/XS)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/share/perl/include
	$(CP) $(PKG_BUILD_DIR)/share/include/XSParseSublike.h $(1)/usr/share/perl/include/
endef

$(eval $(call BuildPackage,perl-xs-parse-sublike))
