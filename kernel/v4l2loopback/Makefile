# This software is in the public domain, furnished "as is", without technical
# support, and with no warranty, express or implied, as to its usefulness for
# any purpose.

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=v4l2loopback
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/umlaeute/v4l2loopback.git
PKG_SOURCE_VERSION:=baf9de279afc7a7c7513e9c40a0c9ff88f456af4
PKG_SOURCE_DATE:=2021-07-13
PKG_MIRROR_HASH:=811a4b0bbefe14cf4a74dbb3d45f5ae147f50f1d67dbb6f0fe3e5a9888adf49a

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

