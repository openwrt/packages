#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id$

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=cryptodev-linux
PKG_VERSION:=1.9.git-2017-10-04
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/cryptodev-linux/cryptodev-linux
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=0a54e38b264d9a3bed74c642a61b88191660d0f8
PKG_MIRROR_HASH:=af3c303afe7ff995b120add6101261a652a6478a2a69018dd740f49a8b14ed09
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=Ansuel Smith <ansuelsmth@gmail.com>

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CRYPTODEV_AUTOLOAD:= \
	cryptodev

define KernelPackage/cryptodev
  SUBMENU:=Cryptographic API modules
  DEFAULT:=m if ALL
  TITLE:=Driver for cryptographic acceleration
  URL:=http://cryptodev-linux.org/
  MAINTAINER:=Nikos Mavrogiannopoulos <n.mavrogiannopoulos@gmail.com>
  VERSION:=$(LINUX_VERSION)+$(PKG_VERSION)-$(BOARD)-$(PKG_RELEASE)
  DEPENDS:=+kmod-crypto-authenc +kmod-crypto-hash
  FILES:= \
		$(PKG_BUILD_DIR)/cryptodev.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,50,$(CRYPTODEV_AUTOLOAD))
  MODPARAMS.cryptodev:= cryptodev_verbosity=-1
endef

define KernelPackage/cryptodev/description
  This is a driver for that allows to use the Linux kernel supported
  hardware ciphers by user-space applications.
endef

CRYPTODEV_MAKEOPTS= -C $(PKG_BUILD_DIR) \
		PATH="$(TARGET_PATH)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		TOOLPREFIX="$(KERNEL_CROSS)" \
		TOOLPATH="$(KERNEL_CROSS)" \
		KERNEL_DIR="$(LINUX_DIR)" \
		LDOPTS=" " \
		DOMULTI=1

define Build/Compile/cryptodev
	$(MAKE) $(CRYPTODEV_MAKEOPTS)
endef

define Build/Compile
	$(call Build/Compile/cryptodev)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/crypto
	$(CP) $(PKG_BUILD_DIR)/crypto/cryptodev.h $(STAGING_DIR)/usr/include/crypto/
endef

$(eval $(call KernelPackage,cryptodev))
