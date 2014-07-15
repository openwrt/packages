#
# Copyright (C) 2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-net-telnet
PKG_VERSION:=3.03
PKG_RELEASE:=1
PKG_MD5SUM:=2f7d34b09d6117baefe89d44cff9d5fc

PKG_SOURCE_URL:=http://search.cpan.org/CPAN/authors/id/J/JR/JROGERS
PKG_SOURCE:=Net-Telnet-$(PKG_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/Net-Telnet-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-net-telnet
SUBMENU:=Perl
SECTION:=lang
CATEGORY:=Languages
TITLE:=Telnet client
URL:=http://search.cpan.org/~jrogers/Net-Telnet-3.03/
DEPENDS:=perl
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-net-telnet/install
	$(call perlmod/Install,$(1),Net auto/Net)
endef

$(eval $(call BuildPackage,perl-net-telnet))
