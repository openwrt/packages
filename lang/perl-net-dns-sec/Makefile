include $(TOPDIR)/rules.mk

PKG_NAME:=perl-net-dns-sec
PKG_VERSION:=1.26
PKG_RELEASE:=1

PKG_SOURCE_NAME:=Net-DNS-SEC
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/N/NL/NLNETLABS
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=88592c65487fb7b4d05134f2f9c48e649a9cd533a8493c50189b649b4ea711a6
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-net-dns-sec
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=DNSSEC extensions to Net::DNS
  URL:=https://metacpan.org/pod/Net::DNS::SEC
  DEPENDS:=perl +perlbase-essential +perlbase-dynaloader +perlbase-file +perlbase-io +perlbase-mime +perl-net-dns +libopenssl
endef

define Package/perl-net-dns-sec/description
  This module extends Net::DNS to support DNSSEC
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-net-dns-sec/install
	$(call perlmod/Install,$(1),Net auto/Net)
endef

$(eval $(call BuildPackage,perl-net-dns-sec))
