#
# Copyright (C) 2007-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=loop-aes
PKG_VERSION:=3.7b
PKG_RELEASE:=1

PKG_MAINTAINER:=Agent 42 <42@enigmabox.net>
PKG_LICENSE:=GPL-3.0+
PKG_SOURCE:=loop-AES-v$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_MD5SUM:=204572f246eddd08705f88189dd3b44d

PKG_BUILD_DIR:=$(BUILD_DIR)/loop-AES-v$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/loop-aes
  SUBMENU:=Cryptographic API modules
  DEPENDS:=@!PACKAGE_kmod-loop
  TITLE:=loopback module with built-in AES
  FILES:=$(PKG_BUILD_DIR)/loop.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,30,loop)
  URL:=http://loop-aes.sourceforge.net
endef

define KernelPackage/loop-aes/description
  This package provides loadable Linux kernel module (loop.o or loop.ko on 2.6
  kernels) that has AES cipher built-in. The AES cipher can be used to encrypt
  local file systems and disk partitions.
endef

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		CC="$(TARGET_CC)" \
		CPP="$(TARGET_CC)" \
		LD="$(TARGET_CROSS)ld" \
		LINUX_SOURCE="$(LINUX_DIR)" \
		KR="$(LINUX_DIR)" \
		MODINST="n" \
		all
endef

$(eval $(call KernelPackage,loop-aes))
