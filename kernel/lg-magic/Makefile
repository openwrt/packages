include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=lg-magic
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/brainrom/lg-magic.git
PKG_SOURCE_DATE:=2025-09-11
PKG_SOURCE_VERSION:=bc22a4e44b9f4acfd04b91ba7e40f4194b2816bf
PKG_MIRROR_HASH:=fb49aaad19ee711226b8bf62ded281e7346750c4e4d08909b2a37ac58765438c

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define KernelPackage/hid-lg-magic
  SUBMENU:=Input modules
  TITLE:=LG Magic Remote HID driver
  URL:=https://github.com/brainrom/lg-magic
  DEPENDS:=+kmod-hid
  FILES:=$(PKG_BUILD_DIR)/kernel/lg_magic.ko
  AUTOLOAD:=$(call AutoProbe,lg_magic)
endef

define KernelPackage/hid-lg-magic/description
  HID driver for the LG Magic Remote (MR20) paired over Bluetooth. It
  maps the remote's buttons, turns the gyroscope into an air mouse and
  can expose the raw IMU data as a separate input device.
endef

define Build/Compile
	$(KERNEL_MAKE) M="$(PKG_BUILD_DIR)/kernel" modules
endef

$(eval $(call KernelPackage,hid-lg-magic))
