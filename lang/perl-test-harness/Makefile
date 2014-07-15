
include $(TOPDIR)/rules.mk

PKG_NAME:=perl-test-harness
PKG_VERSION:=3.25
PKG_RELEASE:=1
PKG_MD5SUM:=69a8a019eeb952fe97e3ac0767c726da

PKG_SOURCE_URL:=http://search.cpan.org/CPAN/authors/id/O/OV/OVID
PKG_SOURCE:=Test-Harness-$(PKG_VERSION).tar.gz

PKG_LICENSE:=GPLv2 ARTISTIC
PKG_LICENSE_FILES:=

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/Test-Harness-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-test-harness
SUBMENU:=Perl
SECTION:=lang
CATEGORY:=Languages
TITLE:=Perl Test Harness
URL:=http://search.cpan.org/~ovid/Test-Harness-3.25/bin/prove
DEPENDS:=+perl
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-test-harness/install
	$(call perlmod/Install,$(1),App auto/Test TAP Test)
endef


$(eval $(call BuildPackage,perl-test-harness))
