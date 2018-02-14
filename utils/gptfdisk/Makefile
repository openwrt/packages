#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gptfdisk
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_MAINTAINER:=Alif M. Ahmad <alive4ever@live.com>
PKG_LICENSE:=GPL-2.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_HASH:=89fd5aec35c409d610a36cb49c65b442058565ed84042f767bba614b8fc91b5c

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/gptfdisk/Default
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Disc
  URL:=http://www.rodsbooks.com/gdisk
  DEPENDS:= +libstdcpp
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
