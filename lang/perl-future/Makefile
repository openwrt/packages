include $(TOPDIR)/rules.mk

PKG_NAME:=perl-future
PKG_VERSION:=0.51
PKG_RELEASE:=1

PKG_SOURCE_NAME:=Future
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/P/PE/PEVANS
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=563ce37383a000ecfd6b7942dd0f4b9fafb2b2c45e0b731029361f261c2f4a36
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-future
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Future represents an operation awaiting completion
  URL:=https://metacpan.org/pod/Future
  DEPENDS:=perl +perlbase-essential +perlbase-b +perlbase-time +perlbase-list
endef

define Package/perl-future/description
  A Future object represents an operation that is currently in progress,
  or has recently completed. It can be used in a variety of ways to manage
  the flow of control, and data, through an asynchronous program.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-future/install
	$(call perlmod/Install,$(1),Future.pm Future)
endef


$(eval $(call BuildPackage,perl-future))
