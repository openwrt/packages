#
# Copyright (C) 2014 Bruno Randolf <br1@einfach.org>
# Copyright (C) 2019 Yousong Zhou <yszhou4tech@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=exfat-nofuse
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/AdrianBan/exfat-nofuse.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2019-09-06
PKG_SOURCE_VERSION:=5536f067373c196f152061f5000fe0032dc07c48
PKG_MIRROR_HASH:=d0922e405f07e9c2f6971a089c90043c72991e926255815c12bf589c369af15b

PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define KernelPackage/fs-exfat
	SUBMENU:=Filesystems
	TITLE:=ExFAT Kernel driver
	FILES:=$(PKG_BUILD_DIR)/exfat.ko
	AUTOLOAD:=$(call AutoLoad,30,exfat,1)
	DEPENDS:=+kmod-nls-base
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
