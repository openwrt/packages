#
# Copyright (C) 2016 Joseph C. Lehner <joseph.c.lehner@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mtd-rw
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jclehner/mtd-rw
PKG_SOURCE_DATE:=2021-02-28
PKG_SOURCE_VERSION:=e87767395a6d27380196702f5f7bf98e92774f3f
PKG_MIRROR_HASH:=984218d7a8e1252419c45ef313f23fb6e5edfa83088f68a4a356b795444ab381

PKG_MAINTAINER:=Joseph C. Lehner <joseph.c.lehner@gmail.com>
PKG_LICENSE=GPL-2.0
PKG_LICENSE_FILES=LICENSE

include $(INCLUDE_DIR)/package.mk

define KernelPackage/mtd-rw
	SUBMENU:=Other modules
	TITLE:=Write-enabler for MTD partitions
	FILES:=$(PKG_BUILD_DIR)/mtd-rw.ko
	DEPENDS:=@!(TARGET_x86||TARGET_bcm27xx||TARGET_octeontx)
endef

define KernelPackage/mtd-rw/description
	A kernel module that temporarily makes all MTD partitions writeable.
endef

MAKE_OPTS:= \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	M="$(PKG_BUILD_DIR)"

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
			$(MAKE_OPTS) \
			CONFIG_MTD_RW=m \
			modules
endef

$(eval $(call KernelPackage,mtd-rw))
