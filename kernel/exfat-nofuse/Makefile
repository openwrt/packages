#
# Copyright (C) 2014 Bruno Randolf <br1@einfach.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=exfat-nofuse
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/coolshou/exfat.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2018-11-06
PKG_SOURCE_VERSION:=2ac42ac44af6e8307e2cdb38febbb6e2b6f9918c
PKG_MIRROR_HASH:=2086f6e6c621390b2ad481f29d60534c6a70a98db97e6e98d1c086b572d2cc4f

PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define KernelPackage/fs-exfat
	SUBMENU:=Filesystems
	TITLE:=ExFAT Kernel driver
	FILES:= \
		$(PKG_BUILD_DIR)/exfat_core.ko \
		$(PKG_BUILD_DIR)/exfat_fs.ko
	AUTOLOAD:=$(call AutoLoad,30,exfat_fs,1)
	DEPENDS:=+kmod-nls-base @BUILD_PATENTED
endef

define KernelPackage/fs-exfat/description
	Kernel module for ExFAT Filesytems
endef

MAKE_OPTS:= \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	M="$(PKG_BUILD_DIR)"

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		$(MAKE_OPTS) \
		CONFIG_EXFAT_FS=m \
		modules
endef

$(eval $(call KernelPackage,fs-exfat))
