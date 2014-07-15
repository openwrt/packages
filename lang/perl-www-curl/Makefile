
include $(TOPDIR)/rules.mk

PKG_NAME:=perl-www-curl
PKG_VERSION:=4.00
PKG_RELEASE:=1
PKG_MD5SUM:=f34eb29f59a811869a4f77bfc0df2f5d

PKG_SOURCE_URL:=http://search.cpan.org/CPAN/authors/id/S/SZ/SZBALINT
PKG_SOURCE:=WWW-Curl-$(PKG_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/WWW-Curl-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-www-curl
SUBMENU:=Perl
SECTION:=lang
CATEGORY:=Languages
TITLE:=Perl bindings to libcurl
URL:=http://search.cpan.org/dist/WWW-Curl/
DEPENDS:=perl +libcurl
endef

define Build/Configure
	$(call perlmod/Configure,$(STAGING_DIR)/usr/include,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-www-curl/install
	$(call perlmod/Install,$(1),WWW/Curl WWW/Curl.pm auto/WWW/Curl)
endef


$(eval $(call BuildPackage,perl-www-curl))
