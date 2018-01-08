#
# Copyright (C) 2014 Bruno Randolf <br1@einfach.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=exfat-nofuse
PKG_VERSION=snapshot-20170619
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://codeload.github.com/dorimanx/$(PKG_NAME)/tar.gz/de4c760?dummy=/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=8cf4c0f6b68ca46ac1581fa56ba2b78246fbe7230190ea38c80e46f48fbcd6cd
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-de4c760

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
