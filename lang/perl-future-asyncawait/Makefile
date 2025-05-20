include $(TOPDIR)/rules.mk

PKG_NAME:=perl-future-asyncawait
PKG_VERSION:=0.70
PKG_RELEASE:=2

PKG_SOURCE_NAME:=Future-AsyncAwait
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/P/PE/PEVANS
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=842899049c977fb2326a8096926441e57beca912bb2b4918d5ce090df4d4a6b7
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=perl-xs-parse-keyword perl-xs-parse-sublike

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-future-asyncawait
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Deferred subroutine syntax for futures in Perl
  URL:=https://metacpan.org/pod/Future::AsyncAwait
  DEPENDS:=perl +perl-future +perl-xs-parse-keyword +perl-xs-parse-sublike +perlbase-xsloader +perlbase-scalar
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-future-asyncawait/install
	$(call perlmod/Install,$(1),Future auto/Future)
endef


$(eval $(call BuildPackage,perl-future-asyncawait))
