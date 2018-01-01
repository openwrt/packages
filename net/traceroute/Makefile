#
# Copyright (C) 2018 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=traceroute
PKG_VERSION:=2.1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0 LGPL-2.1
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_URL:=@SF/traceroute
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=3669d22a34d3f38ed50caba18cd525ba55c5c00d5465f2d20d7472e5d81603b6

include $(INCLUDE_DIR)/package.mk

define Package/traceroute
  SECTION:=net
  CATEGORY:=Network
  TITLE:=tarceroute
  URL:=http://traceroute.sourceforge.net/
endef

define Package/traceroute/description
  A new modern implementation of the traceroute(8) utility for
  Linux systems. It tracks the route packets taken from an IP
  network on their way to a given host.
endef

TARGET_CFLAGS += $(FPIC) -D_GNU_SOURCE

define Package/traceroute/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/traceroute/traceroute $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,traceroute))
