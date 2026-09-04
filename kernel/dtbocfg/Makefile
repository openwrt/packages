# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=dtbocfg
PKG_VERSION:=0.1.1
PKG_RELEASE:=1

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ikwzm/dtbocfg.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=2d6a31ba01d05ab9bd15f127c06fab0e504dd6d7e41115be53e0021e6f8ba877

PKG_MAINTAINER:=Austin Lane <vidplace7@gmail.com>, Tomasz Maciej Nowak <tmn505@gmail.com>
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/fs-dtbocfg
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Filesystem
  URL:=https://github.com/ikwzm/dtbocfg
  TITLE:=Device Tree Blob Overlay Configuration File System
  DEPENDS:=+kmod-fs-configfs @!TARGET_bcm27xx
  FILES:=$(PKG_BUILD_DIR)/dtbocfg.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,31,dtbocfg)
endef

define KernelPackage/fs-dtbocfg/description
  dtbocfg is a kernel module that allows device-tree overlay blobs
  to be loaded and unloaded from a configfs filesystem in userspace.
endef

define Build/Compile
	$(KERNEL_MAKE) M="$(PKG_BUILD_DIR)" modules
endef

$(eval $(call KernelPackage,fs-dtbocfg))
