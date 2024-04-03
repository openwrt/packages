include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=usb-serial-xr_usb_serial_common
PKG_SOURCE_DATE:=2023-03-21
PKG_SOURCE_VERSION:=90ad530166f096347a5a57b6f9eb21c422a40fd9
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/kasbert/epsolar-tracer
PKG_MIRROR_HASH:=ca9e4f48a1a71e8d8e595ce8981a876d11a7d3d0f67b9e68c7825730f2f8756a

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/usb-serial-xr_usb_serial_common
	SECTION:=kernel
	CATEGORY:=Kernel modules
	SUBMENU:=USB Support
	TITLE:=Support for Exar USB to RS-485/RS-422
	URL:=https://www.exar.com/content/document.ashx?id=21651
	FILES:=$(PKG_BUILD_DIR)/xr_usb_serial_common-1a/xr_usb_serial_common.$(LINUX_KMOD_SUFFIX)
	AUTOLOAD:=$(call AutoProbe,xr_usb_serial_common)
	DEPENDS+=kmod-usb-serial
endef

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		M="$(PKG_BUILD_DIR)/xr_usb_serial_common-1a" \
		modules
endef

$(eval $(call KernelPackage,usb-serial-xr_usb_serial_common))
