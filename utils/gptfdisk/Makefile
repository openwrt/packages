#
# Copyright (C) 2016 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gptfdisk
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/gptfdisk
PKG_MD5SUM:=d7f3d306b083123bcc6f5941efade586

include $(INCLUDE_DIR)/package.mk

define Package/gptfdisk/default
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Disc
  URL:=http://www.rodsbooks.com/gdisk
  MAINTAINER:=Daniel Engberg <daniel.engberg.lists@pyret.net>
endef

define Package/gdisk
  $(call Package/gptfdisk/default)
  TITLE:=GPT partition table manipulation utility
  DEPENDS:=+libstdcpp +libuuid +libpopt
endef

define Package/gdisk/description
 GPT partition table manipulation utility with an interface
 similar to fdisk. It can read and convert MBR partitions in GPT
 but is otherwise unable to generate or modify MBR partitions.
endef

define Package/sgdisk
  $(call Package/gptfdisk/default)
  TITLE:=script-friendly GPT partition table manipulation utility
  DEPENDS:=+libstdcpp +libuuid +libpopt
endef

define Package/sgdisk/description
 Script-friendly GPT partition table manipulation utility.
 It can read and convert MBR partitions in GPT but is otherwise
 unable to generate or modify MBR partitions.
 To the contrary of gdisk, its interface is geared towards scripts,
 so it takes command line arguments instead of being interactive.
 It will NOT ask confirmation before carrying out the operations.
 It has a slightly smaller footprint than gdisk tool.
endef

define Package/cgdisk
 $(call Package/gptfdisk/default)
 TITLE:=ncurses-based GPT partition table manipulation utility
 DEPENDS:=+libstdcpp +libuuid +libncurses +libpopt
endef

define Package/cgdisk/description
ncurses-based partition table manipulation utility with GPT support.
Similar to sfdisk, but works with GPT partitions. Shares the same limitations
of the gdisk partition utility. While it can read and convert MBR partitions
in GPT, it cannot modify MBR partitions on its own.
endef

define Package/gdisk/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gdisk $(1)/usr/sbin
endef

define Package/sgdisk/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sgdisk $(1)/usr/sbin
endef

define Package/cgdisk/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cgdisk $(1)/usr/sbin
endef

$(eval $(call BuildPackage,gdisk))
$(eval $(call BuildPackage,sgdisk))
$(eval $(call BuildPackage,cgdisk))
