#
# Copyright (C) 2017 Philip Prindeville <philipp@redfish-solutions.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-authen-sasl-xs
PKG_VERSION:=1.00
PKG_RELEASE:=3

PKG_SOURCE_NAME:=Authen-SASL-XS
PKG_SOURCE_URL:=https://www.cpan.org/authors/id/G/GB/GBARR/
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=1b0eaa0e7ac3a45857147d837e3d34c80c6eca1d9fdcb826a213c2a105454234

PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
PKG_MAINTAINER:=Philip Prindeville <philipp@redfish-solutions.com>, Jens Wagner <jens@wagner2013.de>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perlmod.mk

define Package/perl-authen-sasl-xs
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Authen::XS hooks into libsasl.
  URL:=https://metacpan.org/dist/Authen-SASL-XS/
  DEPENDS:=perl +perlbase-dynaloader +perl-authen-sasl +libsasl2
endef

define Package/perl-authen-sasl-xs/description
  SASL is a generic mechanism for authentication used by several
  network protocols. Authen::SASL::XS provides an implementation
  framework that all protocols should be able to share.
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-authen-sasl-xs/install
	$(call perlmod/Install,$(1),Authen auto/Authen)
endef


$(eval $(call BuildPackage,perl-authen-sasl-xs))
