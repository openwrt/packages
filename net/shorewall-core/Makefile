#
# Copyright (C) 2008-2012 OpenWrt.org
# Copyright (C) 2017 Willem van den Akker <wvdakker@wilsoft.nl>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shorewall-core
PKG_MAJOR_MINOR_VERSION:=5.2
PKG_BUGFIX_MAJOR_VERSION:=8
PKG_BUGFIX_MINOR_VERSION:=
PKG_VERSION:=$(PKG_MAJOR_MINOR_VERSION).$(PKG_BUGFIX_MAJOR_VERSION)$(PKG_BUGFIX_MINOR_VERSION)
PKG_DIRECTORY:=$(PKG_MAJOR_MINOR_VERSION).$(PKG_BUGFIX_MAJOR_VERSION)
PKG_RELEASE:=2

PKG_SOURCE_URL:=https://shorewall.org/pub/shorewall/$(PKG_MAJOR_MINOR_VERSION)/shorewall-$(PKG_DIRECTORY)/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=39996b9697a2017947049ad3f03cb278e8f939ff924b2bb4bf2a0bc17c59988e

PKG_BUILD_DEPENDS:=HOST_OS_MACOS:fakeuname/host

PKG_MAINTAINER:=Willem van den Akker <wvdakker@wilsoft.nl>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
ifeq ($(CONFIG_HOST_OS_MACOS),y)
    include ../../utils/fakeuname/fakeuname.mk
endif

define Package/shorewall-core
    SECTION:=net
    CATEGORY:=Network
    TITLE:=Shorewall Core
    URL:=https://shorewall.org/
    SUBMENU:=Firewall
endef

define Package/shorewall-core/description
	The Shoreline Firewall, is high-level tool for configuring Netfilter.
	This package provides the core Shorewall libraries installed in /usr/share/shorewall/,
	which are required for the rest of the Shorewall packages to work.
endef

define Package/shorewall-core/conffiles
/usr/share/shorewall/shorewallrc
endef

CONFIGURE_ARGS += \
	vendor=openwrt

# MacOS bash is too old for shorewall-core, use OpenWrt host tools/bash built for macos hosts
# use fakeuname to avoid 'if `uname` is Darwin' checks
MACOS_ENV := \
	PATH=$(FAKEUNAME_PATH):$(TARGET_PATH_PKG) \
	$(BASH)

CONFIGURE_VARS += \
	$(if $(CONFIG_HOST_OS_MACOS),$(MACOS_ENV))

define Build/Compile
	DESTDIR=$(PKG_INSTALL_DIR) \
	$(if $(CONFIG_HOST_OS_MACOS),$(MACOS_ENV)) \
	$(PKG_BUILD_DIR)/install.sh
endef

define Package/shorewall-core/install
	$(INSTALL_DIR) $(1)/usr/share/shorewall/
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/shorewall $(1)/usr/share/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/shorewall/wait4ifup $(1)/usr/share/shorewall/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/shorewall $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,shorewall-core))
