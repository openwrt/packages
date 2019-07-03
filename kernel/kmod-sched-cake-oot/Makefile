#
# Copyright (C) 2016 LEDE
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=sched-cake-oot
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/dtaht/sch_cake.git
PKG_SOURCE_DATE:=2019-07-20
PKG_SOURCE_VERSION:=fa556fbdc9d349142c9479863591177e3dcbf64d
PKG_MIRROR_HASH:=c79515d62b68c772990944a985f7d4f2a806aa1cdbc26b17172e752f88cbb0f3
PKG_MAINTAINER:=Kevin Darbyshire-Bryant <ldir@darbyshire-bryant.me.uk>

include $(INCLUDE_DIR)/package.mk

define KernelPackage/sched-cake-oot
  SUBMENU:=Network Support
  TITLE:=OOT Cake fq_codel/blue derived shaper
  URL:=https://github.com/dtaht/sch_cake
  FILES:=$(PKG_BUILD_DIR)/sch_cake.ko
  AUTOLOAD:=$(call AutoProbe,sch_cake)
  DEPENDS:=+kmod-ipt-conntrack
  PROVIDES:=kmod-sched-cake
endef

include $(INCLUDE_DIR)/kernel-defaults.mk

define KernelPackage/sched-cake-oot/description
  O(ut)O(f)T(ree) Common Applications Kept Enhanced fq_codel/blue derived shaper
endef

define Build/Compile
	$(KERNEL_MAKE) SUBDIRS="$(PKG_BUILD_DIR)" modules
endef

$(eval $(call KernelPackage,sched-cake-oot))
