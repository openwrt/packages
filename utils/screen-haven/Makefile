#
# Copyright (C) 2026 LulHaven
#
# This is free software, licensed under the MIT License.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=screen-haven
PKG_VERSION:=1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/mndavew3/screen-haven/releases/download/v$(PKG_VERSION)
PKG_HASH:=5686acc92d46623e72744a5894e45308ce7e70b7a16c2d04b2392ca51bcaec14

PKG_MAINTAINER:=Dave Wengert <dave@lulhaven.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/screen-haven
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Status display for the 3.5in Turing-style USB panel
  URL:=https://lulhaven.com
  DEPENDS:=+zlib
endef

define Package/screen-haven/description
  A table-driven status deck for the 480x320 "Turing" style 3.5-inch USB
  display: live bandwidth graphs, system health, network detail, connected
  devices and a clock. Driven by an attached USB mouse (or wireless air-mouse):
  the scroll wheel slides between screens, clicks step and the middle button
  snapshots. A USB mouse is required.
  Reads only stock system state (/proc, /sys, the default route, dhcp leases,
  uci wireless). Starts automatically when the panel is plugged in.
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(TARGET_LDFLAGS) -Wall \
		-o $(PKG_BUILD_DIR)/screen-haven \
		$(PKG_BUILD_DIR)/screendeck.c $(PKG_BUILD_DIR)/hvn.c \
		$(PKG_BUILD_DIR)/shdata.c $(PKG_BUILD_DIR)/qrcodegen.c \
		-lz
endef

define Package/screen-haven/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/screen-haven $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/screen-haven.init $(1)/etc/init.d/screen-haven
	$(INSTALL_DIR) $(1)/etc/hotplug.d/tty
	$(INSTALL_DATA) ./files/screen-haven.hotplug $(1)/etc/hotplug.d/tty/40-screen-haven
endef

$(eval $(call BuildPackage,screen-haven))
