include $(TOPDIR)/rules.mk

PKG_NAME:=perl-dbd-sqlite
PKG_VERSION:=1.74
PKG_RELEASE:=1

PKG_SOURCE:=DBD-SQLite-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/I/IS/ISHIGAKI/
PKG_HASH:=8994997d84b9feb4547795f78746c661fb72e3cb6a25dbdd789b731f5688a4dd

PKG_MAINTAINER:=Andy Syam <privasisource@gmail.com>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/DBD-SQLite-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=perl-dbi/host

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-dbd-sqlite
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Perl DBD SQLite
  URL:=https://metacpan.org/release/DBD-SQLite
  DEPENDS:=perl +perl-dbi +libsqlite3
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-dbd-sqlite/install
	$(call perlmod/Install,$(1),DBD auto/DBD auto/share)
endef

$(eval $(call BuildPackage,perl-dbd-sqlite))
