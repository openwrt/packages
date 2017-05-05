#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=kernel-packages
PKG_FLAGS:=hold

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/packages
SCAN_DEPS=modules/*.mk $(TOPDIR)/target/linux/*/modules.mk $(TOPDIR)/include/netfilter.mk

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=

export SHELL:=/bin/sh
.ONESHELL:

include $(INCLUDE_DIR)/package.mk

STAMP_BUILT:=$(STAMP_BUILT)_$(firstword $(shell $(SCRIPT_DIR)/kconfig.pl $(LINUX_DIR)/.config | md5sum))

-include $(LINUX_DIR)/.config

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define KernelPackage/depends
endef

CONFIG_PACKAGE_kernel-packages=y
define Package/kernel-packages
  SECTION:=sys
  CATEGORY:=Kernel
  DEFAULT:=y
  TITLE:=Virtual kernel package (in packages feed)
  VERSION:=$(LINUX_VERSION)-$(LINUX_RELEASE)-$(LINUX_VERMAGIC)-packages
  URL:=http://www.kernel.org/
  DEPENDS+=kernel
endef

define Package/kernel-packages/install
  # nothing to do
endef

define Package/kernel-packages/extra_provides
	sed -e 's,.*/,,' $(LINUX_DIR)/modules.builtin;
endef

$(eval $(call BuildPackage,kernel-packages))

include $(sort $(wildcard ./modules/*.mk))
