
include $(TOPDIR)/rules.mk

PKG_NAME:=perl-uri
PKG_VERSION:=1.36
PKG_RELEASE:=1
PKG_MD5SUM:=a97bbdd38b31c6b2672fdc3060fae34b

PKG_SOURCE_URL:=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PKG_SOURCE:=URI-$(PKG_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/URI-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-uri
SUBMENU:=Perl
SECTION:=lang
CATEGORY:=Languages
TITLE:=Manipulates and accesses URI strings
URL:=http://search.cpan.org/dist/URI/
DEPENDS:=perl
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-uri/install
	$(call perlmod/Install,$(1),URI URI.pm)
endef


$(eval $(call BuildPackage,perl-uri))
