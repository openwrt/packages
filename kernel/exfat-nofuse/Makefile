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

PKG_SOURCE_URL:=https://github.com/AndyLavr/exfat-nofuse.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2018-12-18
PKG_SOURCE_VERSION:=c1920b2a18fc01311955f1de668b69c176a452f5
PKG_MIRROR_HASH:=df4593261a44b5ae70de563a403b9caadc62427d5de88eefe5afeb73c31c66bd

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
