include $(TOPDIR)/rules.mk

PKG_NAME:=perl-time-moment
PKG_VERSION:=0.44
PKG_RELEASE:=1

PKG_SOURCE_NAME:=Time-Moment
PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://cpan.metacpan.org/authors/id/C/CH/CHANSEN
PKG_HASH:=64acfa042f634fcef8dadf55e7f42ba4eaab8aaeb7d5212eb89815a31f78f6fd
PKG_BUILD_DIR:=$(BUILD_DIR)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/perl/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Timothy Ace <openwrt@timothyace.com>
PKG_LICENSE:=GPL-1.0-or-later Artistic-1.0-Perl
HOST_BUILD_DEPENDS:=perl/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../perlmod.mk

define Package/perl-time-moment
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Time::Moment Represents a date and time of day with an offset from UTC
  URL:=https://github.com/chansen/p5-time-moment
  DEPENDS:=perl +perlbase-essential +perlbase-time +perlbase-xsloader
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-time-moment/install
        $(call perlmod/Install,$(1),Time auto/Time)
endef

define Host/Configure
        $(call perlmod/host/Configure,,,)
endef

define Host/Compile
        $(call perlmod/host/Compile,,)
endef

define Host/Install
        $(call perlmod/host/Install,$(1),)
endef

$(eval $(call BuildPackage,perl-time-moment))
$(eval $(call HostBuild))
