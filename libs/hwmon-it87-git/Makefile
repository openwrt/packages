#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=hwmon-it87-git
PKG_VERSION:=20240922
PKG_RELEASE:=1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/frankcrawford/it87.git
PKG_SOURCE_VERSION:=213db3aa999e9cb14d8b9a7f84d711e15d2619f6
PKG_MIRROR_HASH:=edf0092c88586333b0642547864f4a030f0b9c6b77e6e9838e5099438c4a8b55

PKG_MAINTAINER:=John Audia <therealgraysky@proton.net>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define KernelPackage/hwmon-it87-git
	TITLE:=IT87 monitoring support (out-of-tree kmod)
	URL:=https://github.com/frankcrawford/it87
	SECTION:=kernel
	CATEGORY:=Kernel modules
	SUBMENU:=Hardware Monitoring Support
	FILES:=$(PKG_BUILD_DIR)/it87.ko
	CONFLICTS:=kmod-hwmon-it87
	DEPENDS:=@TARGET_x86 +kmod-hwmon-vid
	AUTOLOAD:=$(call AutoProbe,it87)
	$(call AddDepends/hwmon,+kmod-i2c-core +kmod-hwmon-vid +PACKAGE_kmod-thermal:kmod-thermal)
endef

define KernelPackage/hwmon-it87-git/description
	This is an out-of-tree it87 module with support for chipsets not yet mainlined,
	for example, the IT86xxE/F series and IT87xxE/F series.
endef

IT87_MAKE_OPTS:= -C $(PKG_BUILD_DIR) \
	PATH="$(TARGET_PATH)" \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	TARGET="$(HAL_TARGET)" \
	TOOLPREFIX="$(KERNEL_CROSS)" \
	TOOLPATH="$(KERNEL_CROSS)" \
	KERNEL_BUILD="$(LINUX_DIR)" \
	LDOPTS=" "

define Build/Compile
	$(MAKE) $(IT87_MAKE_OPTS) M=$(PKG_BUILD_DIR)
endef

$(eval $(call KernelPackage,hwmon-it87-git))
