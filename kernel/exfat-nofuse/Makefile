#
# Copyright (C) 2014 Bruno Randolf <br1@einfach.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=exfat-nofuse
PKG_VERSION=2016-09-26-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

PKG_SOURCE=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/dorimanx/exfat-nofuse.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=051167ceccbe75d9d77fc4f5356f5a39a01779e8

PKG_MAINTAINER:=Bruno Randolf <br1@einfach.org>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define KernelPackage/fs-exfat
	SUBMENU:=Filesystems
	TITLE:=ExFAT Kernel driver
	FILES:=$(PKG_BUILD_DIR)/exfat.ko
	AUTOLOAD:=$(call AutoLoad,30,exfat,1)
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
