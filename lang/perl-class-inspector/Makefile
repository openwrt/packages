include $(TOPDIR)/rules.mk

PKG_NAME:=perl-class-inspector
PKG_VERSION:=1.36
PKG_RELEASE:=1

PKG_SOURCE_NAME:=Class-Inspector
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/P/PL/PLICEASE/
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=cc295d23a472687c24489d58226ead23b9fdc2588e522f0b5f0747741700694e
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-class-inspector
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Class::Inspector - Get information about a class and its structure [Perl]
  URL:=https://metacpan.org/pod/Class::Inspector
  DEPENDS:=perl +perlbase-essential +perlbase-file +perlbase-base
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-class-inspector/install
	$(call perlmod/Install,$(1),Class)
endef


$(eval $(call BuildPackage,perl-class-inspector))
