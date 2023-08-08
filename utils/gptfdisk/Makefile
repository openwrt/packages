#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gptfdisk
PKG_VERSION:=1.0.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_HASH:=dafead2693faeb8e8b97832b23407f6ed5b3219bc1784f482dd855774e2d50c2

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=gc-sections lto

include $(INCLUDE_DIR)/package.mk

define Package/gptfdisk/Default
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Disc
  URL:=https://www.rodsbooks.com/gdisk
  DEPENDS:=+libstdcpp
endef

define Package/gdisk
$(call Package/gptfdisk/Default)
  TITLE:=GPT aware disk manipulation utility for interactive use
  DEPENDS+= +libuuid
endef

define Package/gdisk/description
  gdisk is GPT aware disk partitioning tool, with interactive UI.
endef

define Package/cgdisk
$(call Package/gptfdisk/Default)
  TITLE:=GPT aware disk manipulation utility for interactive use
  DEPENDS+= +libuuid +libncursesw
endef

define Package/cgdisk/description
  cgdisk is GPT aware disk partitioning tool, with interactive ncurses based UI.
endef

define Package/sgdisk
$(call Package/gptfdisk/Default)
  TITLE:=GPT aware disk manipulation utility for scripting use
  DEPENDS+= +libuuid +libpopt
endef

define Package/sgdisk/description
  sgdisk is GPT-aware disk partitioning tool for scripting use.
endef

define Package/fixparts
$(call Package/gptfdisk/Default)
  TITLE:=A utility to fix corrupted MBR partitions
  DEPENDS+=
endef

define Package/fixparts/description
  a text-mode menu-driven program for repairing certain types of problems with
  Master Boot Record (MBR) partition tables
endef

TARGET_CXXFLAGS += -std=c++11 -fno-rtti
TARGET_LDFLAGS += -Wl,--as-needed
MAKE_FLAGS += TARGET=linux

define Package/gdisk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gdisk $(1)/usr/bin/
endef

define Package/cgdisk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cgdisk $(1)/usr/bin/
endef

define Package/sgdisk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sgdisk $(1)/usr/bin/
endef

define Package/fixparts/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fixparts $(1)/usr/bin/
endef

$(eval $(call BuildPackage,gdisk))
$(eval $(call BuildPackage,cgdisk))
$(eval $(call BuildPackage,sgdisk))
$(eval $(call BuildPackage,fixparts))
