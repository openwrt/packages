#
# Copyright (C) 2008-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=v4l2loopback
PKG_VERSION:=master
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/umlaeute/v4l2loopback
PKG_SOURCE_VERSION:=baf9de279afc7a7c7513e9c40a0c9ff88f456af4
PKG_MIRROR_HASH:=ff834e16b13e9b38814095d95ab033ea7eae075689956e227f157e95bc075983


PKG_MAINTAINER:=Michel Promonet <michel.promonet@free.fr>

include $(INCLUDE_DIR)/package.mk

define KernelPackage/v4l2loopback
  SUBMENU:=Video Support
  TITLE:=v4l2loopback kernel module
  FILES:=$(PKG_BUILD_DIR)/v4l2loopback.ko
  DEPENDS:=+kmod-video-core +kmod-video-videobuf2
  AUTOLOAD:=$(call AutoProbe,v4l2loopback)
endef

define KernelPackage/v4l2loopback/description
	This module allows you to create "virtual video devices".
	Normal (v4l2) applications will read these devices as if
	they were ordinary video devices, but the video will not be
	read from e.g. a capture card but instead it is generated
	by another application. 
endef

MAKE_OPTS:= \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	M="$(PKG_BUILD_DIR)"

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		$(MAKE_OPTS) \
		CONFIG_PACKAGE_kmod-v4l2loopback=m \
		modules
endef

$(eval $(call KernelPackage,v4l2loopback))

