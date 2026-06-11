include $(TOPDIR)/rules.mk

PKG_NAME:=perl-struct-dumb
PKG_VERSION:=0.14
PKG_RELEASE:=1

PKG_SOURCE_NAME:=Struct-Dumb
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/P/PE/PEVANS
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=13c148536b10e28c6e0b4e132f29e4ca6e69b5749059c44157a27e84a5459436
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-struct-dumb
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Make simple lightweight record-like structures
  URL:=https://metacpan.org/pod/Struct::Dumb
  DEPENDS:=perl +perlbase-essential +perlbase-scalar
endef

define Package/perl-struct-dumb/description
  Struct::Dumb creates record-like structure types,
  similar to the struct keyword in C, C++ or Record in Pascal.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-struct-dumb/install
	$(call perlmod/Install,$(1),Struct)
endef

$(eval $(call BuildPackage,perl-struct-dumb))

