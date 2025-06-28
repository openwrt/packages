include $(TOPDIR)/rules.mk

PKG_NAME:=perl-xs-parse-keyword
PKG_VERSION:=0.48
PKG_RELEASE:=1

PKG_SOURCE_NAME:=XS-Parse-Keyword
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/P/PE/PEVANS
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=857a070ba465ab5b89d4d8d36d92358edd66e5e7b4a91584611d85125ac9a9c7
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-xs-parse-keyword
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=XS functions to assist in parsing keyword syntax
  URL:=https://metacpan.org/pod/XS::Parse::Keyword
  DEPENDS:=perl +perlbase-essential +perlbase-xsloader
endef

define Package/perl-xs-parse-keyword/description
  This module provides some XS functions to assist in writing syntax
  modules that provide new Perl-visible syntax, primarily for authors
  of keyword plugins using the PL_keyword_plugin hook mechanism.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-xs-parse-keyword/install
	$(call perlmod/Install,$(1),XS auto/XS)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/share/perl/include
	$(CP) $(PKG_BUILD_DIR)/share-infix/include/XSParseInfix.h $(1)/usr/share/perl/include/
	$(CP) $(PKG_BUILD_DIR)/share-keyword/include/XSParseKeyword.h $(1)/usr/share/perl/include/
endef

$(eval $(call BuildPackage,perl-xs-parse-keyword))
