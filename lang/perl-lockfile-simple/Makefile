
include $(TOPDIR)/rules.mk

PKG_NAME:=perl-lockfile-simple
PKG_VERSION:=0.206
PKG_RELEASE:=1
PKG_MD5SUM:=d8966c3fb799aefcaaf80f845057a1fa

PKG_SOURCE_URL:=http://search.cpan.org/CPAN/authors/id/J/JV/JV
PKG_SOURCE:=LockFile-Simple-$(PKG_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/LockFile-Simple-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-lockfile-simple
SUBMENU:=Perl
SECTION:=lang
CATEGORY:=Languages
TITLE:=Simple advisory file locking
URL:=http://search.cpan.org/dist/LockFile-Simple/
DEPENDS:=perl
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-lockfile-simple/install
	$(call perlmod/Install,$(1),LockFile auto/LockFile)
endef


$(eval $(call BuildPackage,perl-lockfile-simple))
