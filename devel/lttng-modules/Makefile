#
# Copyright (C) 2013-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lttng-modules
PKG_VERSION:=2.13.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://lttng.org/files/$(PKG_NAME)/
PKG_HASH:=bf808b113544287cfe837a6382887fa66354ef5cc8216460cebbef3d27dc3581

PKG_MAINTAINER:=
PKG_LICENSE:=LGPL-2.1 GPL-2.0 MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/lttng
  SUBMENU:=Other modules
  TITLE:=Linux Trace Toolkit: next generation (kernel modules)
  URL:=https://lttng.org/
  DEPENDS:=@!TARGET_uml @KERNEL_FTRACE_SYSCALLS @KERNEL_KPROBES
  FILES:= \
	$(PKG_BUILD_DIR)/src/lttng-*.$(LINUX_KMOD_SUFFIX) \
	$(PKG_BUILD_DIR)/src/lib/lttng-*.$(LINUX_KMOD_SUFFIX) \
	$(PKG_BUILD_DIR)/src/probes/lttng-*.$(LINUX_KMOD_SUFFIX)
endef

define Build/Compile
	+$(KERNEL_MAKE) $(PKG_JOBS) \
		M="$(PKG_BUILD_DIR)" \
		CONFIG_LTTNG=m \
		modules
endef

$(eval $(call KernelPackage,lttng))
