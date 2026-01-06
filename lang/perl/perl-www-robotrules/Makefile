include $(TOPDIR)/rules.mk

PKG_NAME:=perl-www-robotrules
PKG_VERSION:=6.02
PKG_RELEASE:=3

METACPAN_NAME:=WWW-RobotRules
METACPAN_AUTHOR:=GAAS
PKG_HASH:=46b502e7a288d559429891eeb5d979461dd3ecc6a5c491ead85d165b6e03a51e

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_LICENSE_FILES:=LICENSE

include ../metacpan.mk
include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-www-robotrules
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=database of robots.txt-derived permissions
  URL:=https://metacpan.org/pod/WWW::RobotRules
  DEPENDS:=perl +perlbase-anydbm-file +perlbase-essential +perlbase-fcntl +perl-uri
endef

define Package/perl-www-robotrules/description
  This module parses /robots.txt files.
endef

define Build/Configure
    $(call perlmod/Configure,,)
endef

define Build/Compile
    $(call perlmod/Compile,,)
endef

define Package/perl-www-robotrules/install
    $(call perlmod/Install,$(1),WWW)
endef

$(eval $(call BuildPackage,perl-www-robotrules))
