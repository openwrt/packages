#
# Copyright (C) 2013-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lttng-modules
PKG_VERSION:=2.6.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://lttng.org/files/$(PKG_NAME)/
PKG_MD5SUM:=a058ab037daaca293a54934d7b9f9c98

PKG_LICENSE:=LGPL-2.1 GPL-2.0 MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/lttng
  SUBMENU:=Other modules
  TITLE:=Linux Trace Toolkit: next generation (kernel modules)
  URL:=https://lttng.org/
  DEPENDS:= @!TARGET_uml @KERNEL_FTRACE
  FILES:= \
	$(PKG_BUILD_DIR)/lttng-*.$(LINUX_KMOD_SUFFIX) \
	$(PKG_BUILD_DIR)/lib/lttng-*.$(LINUX_KMOD_SUFFIX) \
	$(PKG_BUILD_DIR)/probes/lttng-*.$(LINUX_KMOD_SUFFIX)
endef

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		SUBDIRS="$(PKG_BUILD_DIR)" \
		V="$(V)" \
		modules
endef

$(eval $(call KernelPackage,lttng))
