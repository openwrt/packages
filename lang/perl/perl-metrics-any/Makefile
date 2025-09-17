include $(TOPDIR)/rules.mk

PKG_NAME:=perl-metrics-any
PKG_VERSION:=0.10
PKG_RELEASE:=1

PKG_SOURCE_NAME:=Metrics-Any
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/P/PE/PEVANS
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=a90eadf9c8af24a516bb9a1b67061f641853f90b8fee9ffc24d2bb9720e8b99b
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-metrics-any
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Abstract collection of monitoring metrics
  URL:=https://metacpan.org/pod/Metrics::Any
  DEPENDS:=perl +perlbase-list
endef

define Package/perl-metrics-any/description
  Provides a central location for modules to report monitoring metrics.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-metrics-any/install
	$(call perlmod/Install,$(1),Metrics)
endef

$(eval $(call BuildPackage,perl-metrics-any))
