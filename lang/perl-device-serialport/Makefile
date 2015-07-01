#
# Copyright (C) 2014, 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-device-serialport
PKG_VERSION:=1.04
PKG_RELEASE:=3

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/C/CO/COOK/
PKG_SOURCE:=Device-SerialPort-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=82c698151f934eb28c65d1838cee7d9e

PKG_LICENSE:=GPL-1.0+ Artistic-1.0-Perl
PKG_MAINTAINER:=Paul Oranje <por@xs4all.nl>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/Device-SerialPort-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../perl/perlmod.mk

define Package/perl-device-serialport
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A POSIX-based version of the Win32::SerialPort module
  URL:=http://search.cpan.org/dist/Device-SerialPort/
  DEPENDS:=perl +perlbase-essential +perlbase-io +perlbase-posix +perlbase-test +perlbase-xsloader
endef

define Package/perl-device-serialport/description
  A POSIX-based version of the Win32::SerialPort module
  that provides modem support to Perl applications
endef

define Build/Configure
	$(call perlmod/Configure,,)
endef

define Build/Compile
	$(call perlmod/Compile,,)
endef

define Package/perl-device-serialport/install
        $(call perlmod/Install,$(1),Device auto/Device)
endef


$(eval $(call BuildPackage,perl-device-serialport))
