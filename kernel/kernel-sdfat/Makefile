#
# Copyright (C) 2018 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=kernel-sdfat
PKG_VERSION:=20180522
PKG_RELEASE:=1
PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_URL:=https://codeload.github.com/cryptomilk/$(PKG_NAME)/tar.gz/aa8183f?dummy=/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=17e171bd9d6cdcb617d2e92ec8c06c308108e61fdf6ff70bcb1335b59d4d2c44
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-aa8183f

include $(INCLUDE_DIR)/package.mk

define KernelPackage/fs-sdfat
  SUBMENU:=Filesystems
  TITLE:=sdFAT kernel driver
  FILES:=$(PKG_BUILD_DIR)/sdfat_fs.ko
  AUTOLOAD:=$(call AutoLoad,30,sdfat_fs,1)
  DEPENDS:=+kmod-nls-base +kmod-nls-utf8 +kmod-nls-cp437 +kmod-nls-iso8859-1 @BUILD_PATENTED
endef

define KernelPackage/fs-sdfat/description
	Kernel module for FAT12/16/32/VFAT and exFAT filesytems
endef

MAKE_OPTS:= \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	M="$(PKG_BUILD_DIR)"

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
			$(MAKE_OPTS) \
			CONFIG_SDFAT_FS=m \
			modules
endef

$(eval $(call KernelPackage,fs-sdfat))
