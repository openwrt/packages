#
# Copyright (C) 2021 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-try-tiny
PKG_VERSION:=0.31
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/E/ET/ETHER/
PKG_SOURCE:=Try-Tiny-$(PKG_VERSION).tar.gz
PKG_HASH:=3300d31d8a4075b26d8f46ce864a1d913e0e8467ceeba6655d5d2b2e206c11be
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/Try-Tiny-$(PKG_VERSION)

PKG_MAINTAINER:=Matt Merhar <mattmerhar@protonmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-try-tiny
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Minimal try/catch with proper preservation of $$$$@
  URL:=https://metacpan.org/pod/Try::Tiny
  DEPENDS:=perl +perlbase-essential
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-try-tiny/install
	$(call perlmod/Install,$(1),Try auto/Try)
endef

$(eval $(call BuildPackage,perl-try-tiny))
