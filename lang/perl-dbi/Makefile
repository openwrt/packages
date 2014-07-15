
include $(TOPDIR)/rules.mk

PKG_NAME:=perl-dbi
PKG_VERSION:=1.604
PKG_RELEASE:=1
PKG_MD5SUM:=358511d60eb3daba913d49236c469802

PKG_SOURCE_URL:=http://search.cpan.org/CPAN/authors/id/T/TI/TIMB/
PKG_SOURCE:=DBI-$(PKG_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/DBI-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-dbi
SUBMENU:=Perl
SECTION:=lang
CATEGORY:=Languages
TITLE:=Database independent interface for Perl
URL:=http://search.cpan.org/dist/DBI/
DEPENDS:=perl +perlbase-essential
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-dbi/install
	$(call perlmod/Install,$(1),DB* auto/DBI,DBI/W32ODBC.pm auto/DBI/*.h)
endef


$(eval $(call BuildPackage,perl-dbi))
