include $(TOPDIR)/rules.mk

PKG_NAME:=perl-file-sharedir
PKG_VERSION:=1.118
PKG_RELEASE:=1

PKG_SOURCE_NAME:=File-ShareDir
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/R/RE/REHSACK/
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=3bb2a20ba35df958dc0a4f2306fc05d903d8b8c4de3c8beefce17739d281c958
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-file-sharedir
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Locate per-dist and per-module shared files
  URL:=https://metacpan.org/pod/File::ShareDir
  DEPENDS:=perl +perlbase-essential +perlbase-file +perl-class-inspector
endef

define Package/perl-file-sharedir/description
  File::ShareDir locates shared files distributed with a Perl distribution
  or module.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-file-sharedir/install
	$(call perlmod/Install,$(1),File)
endef


$(eval $(call BuildPackage,perl-file-sharedir))
