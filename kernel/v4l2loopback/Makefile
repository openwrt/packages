# This software is in the public domain, furnished "as is", without technical
# support, and with no warranty, express or implied, as to its usefulness for
# any purpose.

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=v4l2loopback
PKG_VERSION:=0.13.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/umlaeute/v4l2loopback
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=06b786138b35daab3edfafb95432f1b838676e6dd615c481eae0553182eac67b

PKG_MAINTAINER:=Michel Promonet <michel.promonet@free.fr>
PKG_CPE_ID:=cpe:/o:v4l2loopback_project:v4l2loopback

include $(INCLUDE_DIR)/package.mk

define KernelPackage/v4l2loopback
  SUBMENU:=Video Support
  TITLE:=v4l2loopback kernel module
  FILES:=$(PKG_BUILD_DIR)/v4l2loopback.ko
  DEPENDS:=+kmod-video-core 
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

