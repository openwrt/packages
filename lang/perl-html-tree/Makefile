
include $(TOPDIR)/rules.mk

PKG_NAME:=perl-html-tree
PKG_VERSION:=3.23
PKG_RELEASE:=2
PKG_MD5SUM:=6352f50be402301f79b580dd235d7762

PKG_SOURCE_URL:=http://search.cpan.org/CPAN/authors/id/P/PE/PETEK
PKG_SOURCE:=HTML-Tree-$(PKG_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/HTML-Tree-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-html-tree
SUBMENU:=Perl
SECTION:=lang
CATEGORY:=Languages
TITLE:=represent and create HTML syntax trees
URL:=http://search.cpan.org/dist/HTML-Tree/
DEPENDS:=perl +perl-html-parser +perl-html-tagset
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-html-tree/install
	$(call perlmod/Install,$(1),HTML)
endef


$(eval $(call BuildPackage,perl-html-tree))
