include $(TOPDIR)/rules.mk

PKG_NAME:=perl-dbd-pg
PKG_VERSION:=3.18.0
PKG_RELEASE:=1

PKG_SOURCE:=DBD-Pg-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/T/TU/TURNSTEP/
PKG_HASH:=92bbe8a363040f8ce6a3f1963f128132e245861a9b4dc5a84178b42d625a7807

PKG_MAINTAINER:=Andy Syam <privasisource@gmail.com>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/DBD-Pg-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=perl-dbi/host postgresql/host

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-dbd-pg
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Perl DBD Pg
  URL:=https://metacpan.org/dist/DBD-Pg
  DEPENDS:=perl +perl-dbi +libpq
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-dbd-pg/install
	$(call perlmod/Install,$(1),DBD auto/DBD auto/share)
endef

$(eval $(call BuildPackage,perl-dbd-pg))
