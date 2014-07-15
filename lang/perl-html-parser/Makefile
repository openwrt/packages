
include $(TOPDIR)/rules.mk

PKG_NAME:=perl-html-parser
PKG_VERSION:=3.56
PKG_RELEASE:=1
PKG_MD5SUM:=bddc432e5ed9df4d4153a62234f04fc2

PKG_SOURCE_URL:=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PKG_SOURCE:=HTML-Parser-$(PKG_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/HTML-Parser-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-html-parser
SUBMENU:=Perl
SECTION:=lang
CATEGORY:=Languages
TITLE:=A collection of modules that parse HTML text documents
URL:=http://search.cpan.org/dist/HTML-Parser/
DEPENDS:=perl +perl-html-tagset +perl-uri
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-html-parser/install
	$(call perlmod/Install,$(1),HTML auto/HTML)
endef


$(eval $(call BuildPackage,perl-html-parser))
